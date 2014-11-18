/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 File:	 JRConnectionManager.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:	 Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "NSMutableURLRequest+JRRequestUtils.h"
#import "JRConnectionManager.h"
#import "debug_log.h"

@implementation NSString (JRString_UrlEscaping)
- (NSString *)stringByAddingUrlPercentEscapes
{

    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (CFStringRef) self,
            NULL,
            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
            kCFStringEncodingUTF8));

    return encodedString;
}
@end


/**
 * @brief Stores the NSURLConnection and other connection data
 *
 *  ConnectionData is the root object that is collected by
 *  JRConnectionManager in an NSMutableArray. This object is not intended to
 *  be used in a public interface
 *
 * @sa
 * For more information of Janrain Engage's activity api, see
 * <a href="http://documentation.janrain.com/activity">the activity section</a> of our API Documentation.
 **/
@interface ConnectionData : NSObject
{
}

@property           NSURLRequest    *request;
@property           NSMutableData   *response;
@property           NSURLResponse   *fullResponse;
@property(readonly) id              tag;
@property(readonly) BOOL            returnFullResponse;
@property(readonly) id <JRConnectionManagerDelegate> delegate;

// NOTE that NSURLConnection objects are not copyable
@property           NSURLConnection* connection;
@end

@implementation ConnectionData

- (id)copyWithZone:(NSZone*)zone
{
    ConnectionData *objectCopy = [[[self class] allocWithZone:zone] init];
    
    objectCopy.request      = self.request;
    objectCopy.response     = self.response;
    objectCopy.fullResponse = self.fullResponse;
    objectCopy->_tag        = self.tag;
    objectCopy->_returnFullResponse = self.returnFullResponse;
    objectCopy->_delegate   = self.delegate;
    objectCopy->_connection = self.connection;
    return objectCopy;
}

- (id)initWithRequest:(NSURLRequest *)request
          forDelegate:(id <JRConnectionManagerDelegate>)delegate
       withConnection:(NSURLConnection*)connection
   returnFullResponse:(BOOL)returnFullResponse
              withTag:(id)userdata
{
    //DLog(@"");

    if ((self = [super init]))
    {
        [self setRequest:request];
        self->_tag = userdata;
        self->_returnFullResponse = returnFullResponse;
        _response = nil;
        _fullResponse = nil;
        self->_delegate = delegate;
        self->_connection = connection;
    }
    return self;
}
@end


/**
 * @brief JRConnectionManager category that hides the internal collection
 * of ConnectionData objects
 *
 **/
@interface JRConnectionManager()
@property NSMutableArray *connectionBuffers;
@end




@implementation JRConnectionManager

static JRConnectionManager *singleton = nil;


+ (id)getJRConnectionManager
{
    if (singleton == nil)
    {
        singleton = [((JRConnectionManager *) [super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getJRConnectionManager];
}

- (id)copyWithZone:(__unused NSZone *)zone __unused
{
    return self;
}

+ (NSUInteger)openConnections
{
    JRConnectionManager *connectionManager = [JRConnectionManager getJRConnectionManager];
    return [[connectionManager connectionBuffers] count];
}

+ (ConnectionData*) getConnectionDataFromConnection:(NSURLConnection *)connection
{
    for (ConnectionData* connectionData in [JRConnectionManager getConnectionBuffers])
    {
        if (connectionData.connection == connection)
        {
            return connectionData;
        }
    }
    return nil;
}

+ (NSMutableArray *) getConnectionBuffers
{
    JRConnectionManager *connectionManager = [JRConnectionManager getJRConnectionManager];
    return [connectionManager connectionBuffers];
}

+ (bool)createConnectionFromRequest:(NSURLRequest *)request
                        forDelegate:(id <JRConnectionManagerDelegate>)delegate
                 returnFullResponse:(BOOL)returnFullResponse
                            withTag:(id)userData
{
    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    DLog(@"request to '%@' with body: '%@'", [[request URL] absoluteString], body);

    JRConnectionManager *connectionManager = [JRConnectionManager getJRConnectionManager];
    NSMutableArray *connectionBuffers = [connectionManager connectionBuffers];

    if (![NSURLConnection canHandleRequest:request])
        return NO;

    NSURLConnection *connection = [[NSURLConnection alloc]
            initWithRequest:request delegate:connectionManager startImmediately:NO];

    if (!connection)
        return NO;

    ConnectionData *connectionData = [[ConnectionData alloc] initWithRequest:request
                                                                 forDelegate:delegate
                                                              withConnection:connection
                                                          returnFullResponse:returnFullResponse
                                                                     withTag:userData];
    [connectionBuffers addObject:connectionData];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    [connectionManager startActivity];

    return YES;
}

+ (bool)createConnectionFromRequest:(NSURLRequest *)request
                        forDelegate:(id <JRConnectionManagerDelegate>)delegate
                            withTag:(id)userData
{
    return [JRConnectionManager createConnectionFromRequest:request forDelegate:delegate returnFullResponse:NO
                                                    withTag:userData];
}

+ (void)stopConnectionsForDelegate:(id <JRConnectionManagerDelegate>)delegate
{
    DLog(@"delegate=%@", delegate.debugDescription);
    for (ConnectionData *connectionData in [JRConnectionManager getConnectionBuffers])
    {
        if (connectionData.delegate == delegate)
        {
            [connectionData.connection cancel];

            if ([connectionData tag])
            {
                if ([delegate respondsToSelector:@selector(connectionWasStoppedWithTag:)])
                    [delegate connectionWasStoppedWithTag:[connectionData tag]];
            }

            [[JRConnectionManager getConnectionBuffers] removeObject:connectionData];
        }
    }

    [[JRConnectionManager getJRConnectionManager] stopActivity];
}

+ (void)jsonRequestToUrl:(NSString *)url params:(NSDictionary *)params
     completionHandler:(void(^)(id parsedResponse, NSError *e))handler
{
    DLog(@"url=%@", url);
    NSURLRequest *request = [NSMutableURLRequest JR_requestWithURL:[NSURL URLWithString:url] params:params];
    [JRConnectionManager startURLConnectionWithRequest:request completionHandler:handler];
}

+ (void)startURLConnectionWithRequest:(NSURLRequest *)request
                    completionHandler:(void(^)(id parsedResponse, NSError *e))handler
{
    NSString *p = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSString *url = [request.URL absoluteString];
    DLog(@"URL: \"%@\" params: \"%@\"", url, p);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
                           {
                               if (e)
                               {
                                   ALog(@"Error fetching JSON: %@", e);
                                   handler(nil, e);
                               }
                               else
                               {
                                   NSString *bodyString =
                                           [[NSString alloc] initWithData:d
                                                                  encoding:NSUTF8StringEncoding];
                                   NSError *err = nil;
                                   id parsedJson = [NSJSONSerialization JSONObjectWithData:d
                                                                                   options:(NSJSONReadingOptions) 0
                                                                                     error:&err];
                                   ALog(@"Fetched: \"%@\"", bodyString);
                                   if (err)
                                   {
                                       ALog(@"Parse err: \"%@\"", err);
                                       handler(nil, e);
                                   }
                                   else
                                   {
                                       handler(parsedJson, nil);
                                   }
                               }
                           }];
}


- (JRConnectionManager *)init
{
    if ((self = [super init]))
    {
        _connectionBuffers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)startActivity
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)stopActivity
{
    if ([[self connectionBuffers] count] == 0)
    {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}

- (void)dealloc
{
    DLog(@"");
    NSEnumerator *enumerator = [[self connectionBuffers] objectEnumerator];
    ConnectionData *connectionData;
    while ((connectionData = [enumerator nextObject]))
    {
        [connectionData.connection cancel];
        
        if ([connectionData tag])
        {
            [[connectionData delegate] connectionWasStoppedWithTag:[connectionData tag]];
        }
        
        [[self connectionBuffers] removeObject:connectionData];
    }
    [self stopActivity];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    for (ConnectionData *connectionData in [self connectionBuffers])
    {
        if (connectionData.connection == connection)
        {
            [[connectionData response] appendData:data];
            break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    DLog(@"response=%@", response.URL.absoluteString);
    for (ConnectionData *connectionData in [self connectionBuffers])
    {
        if (connectionData.connection == connection)
        {
            [connectionData setResponse:[[NSMutableData alloc] init]];
            if ([connectionData returnFullResponse])
                connectionData.fullResponse = response;
            break;
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"connection=%@", connection.description);
    
    ConnectionData *connectionData  = [JRConnectionManager getConnectionDataFromConnection:connection];
    if (!connectionData || (connectionData.connection != connection))
    {
        return;
    }
    
    NSURLRequest*   request         = [connectionData request];
    NSURLResponse*  fullResponse    = [connectionData fullResponse];
    NSData*         responseBody    = [connectionData response];
    id              userData        = [connectionData tag];
    NSStringEncoding encoding       = NSUTF8StringEncoding;
    
    id <JRConnectionManagerDelegate> delegate = [connectionData delegate];

    if (![connectionData fullResponse])
    {
        NSString *payload = [[NSString alloc] initWithData:responseBody encoding:encoding];

        if ([delegate respondsToSelector:@selector(connectionDidFinishLoadingWithPayload:request:andTag:)])
            [delegate connectionDidFinishLoadingWithPayload:payload request:request andTag:userData];
    }
    else
    {
        SEL finishMsg = @selector(connectionDidFinishLoadingWithFullResponse:unencodedPayload:request:andTag:);
        if ([delegate respondsToSelector:finishMsg])
            [delegate connectionDidFinishLoadingWithFullResponse:fullResponse unencodedPayload:responseBody
                                                         request:request andTag:userData];
    }

    JRConnectionManager *connectionManager = [JRConnectionManager getJRConnectionManager];
    [[connectionManager connectionBuffers] removeObject:connectionData];

    [self stopActivity];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"error message: %@", [error localizedDescription]);

    ConnectionData* connectionData  = [JRConnectionManager getConnectionDataFromConnection:connection];
    NSURLRequest*   request         = [connectionData request];
    id              userData        = [connectionData tag];
    
    id <JRConnectionManagerDelegate> delegate = [connectionData delegate];

    if ([delegate respondsToSelector:@selector(connectionDidFailWithError:request:andTag:)])
        [delegate connectionDidFailWithError:error request:request andTag:userData];

    JRConnectionManager *connectionManager = [JRConnectionManager getJRConnectionManager];
    [[connectionManager connectionBuffers] removeObject:connectionData];

    [self stopActivity];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    DLog(@"request to '%@' with body: '%@'", [[request URL] absoluteString], body);
    ConnectionData* connectionData  = [JRConnectionManager getConnectionDataFromConnection:connection];

    if ([connectionData returnFullResponse])
        connectionData.fullResponse = redirectResponse;

    return request;
}

- (void)              connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    DLog(@"");
}

- (void)               connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    DLog(@"");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    /*DLog(@"");*/
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //DLog(@"bytesWritten: %d, totalBytesWritten: %d, totalBytesExpected: %d", bytesWritten, totalBytesWritten,
    //    totalBytesExpectedToWrite);
}

@end
