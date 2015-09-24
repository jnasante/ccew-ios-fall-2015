Session: Connecting to Network Services
=====

For this final lesson we'll connect to an API, fetch data to display in a custom table view, and post new data to the API.

## Secure Transport

HTTPS is required by iOS 9 for all API network communication. A emporary workaround for insecure communication with any server adds the `NSAppTransportSecurity` key to your application's info.plist file or in the Info target settings with a dictionary that contains a single key-value pair: `NSAllowsArbitraryLoads: YES`.

This is a general workaround. You should require that the server employ HTTPS. If it does not, rather than adding a workaround for any server you should allow insecure transport for a single server. See [this post](http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http) on Stack Overflow for more information.

## JSON

JSON is the JavaScript Object Notation and is a serialized representation of a JavaScript object in a plain text form suitable for network transport. A JavaScript object is like an NSDictionary in Objective-C, or a collection of key-value pairs that supports nesting.

Serialization and deserialization are technical terms for the processes of converting data from an in-memory representation to a persistent representation (disk, network, etc) and back. Some formats use binary data, which may be very close to the actual data in memory. JSON uses a human readable plain text representation that makes debugging easy.

JSON supports one of two representations for network transport: as a list (or array) or as an object (or dictionary). This means you can send and receive either instances of NSArray or NSDictionary to and from API servers. Lists are often lists of objects, so you will often be working with arrays of dictionaries.

It will be the responsibility of our application to serialize between JSON and the actual data represented, i.e. the arrays and  dictionaries and the basic values they contain, such as numbers and strings.

In general, however, we'll be working with model objects that have properties. We'll then need to convert from JSON to dictionaries to model objects and back, like so:

```
JSON --deserialize--> NSDictionary --instantiate--> Model Object

Model Object --representation as--> NSDictionary --serialize--> JSON
```

We'll use utility methods on our model objects and the built-in APIs for serializing and deserializing JSON to do this.

## The Architecture

We're going to add another layer to our application architecture. So far we've learned how to use the Model-View-Controller (MVC) design pattern to organize our code. With MVC our code is modular with clear boundaries for functionality and classes isolated from one another. Models and Views don't know anything about one another while Controllers mediate between the two.

We'll add a Network layer following these design principles. Our Models and Views won't know anything about our Network code, and vice versa. Once again it will be the responsibility of our Controllers to mediate between the Model, Network, and Views.

## Simple Model Object

We'll be looking at a simple application for displaying a list of "blog posts" from a server and creating new blog posts. We have one model object, the Post object, that encapsulates information about a post, including its ID, title, body and author.

The class definition is straightforward:

**Post.h**

```obj-c
#import <Foundation/Foundation.h>

@interface Post : NSObject

@property NSString *ID;
@property NSString *title;
@property NSString *body;
@property NSNumber *author;

- (id) initWithDictionary:(NSDictionary*)aDictionary;
- (NSDictionary*) dictionaryRepresentation;

@end
```

Notice that we're providing two methods for transforming a dictinoary into a post and for transforming a post into a dictionary. Those methods are implemented as follows:

**Post.m**

```obj-c
#import "Post.h"

@implementation Post

- (id) initWithDictionary:(NSDictionary*)aDictionary {
    if ((self=[super init])) {
        
        // Normally you want to access properties with self.prop notation
        // But during method initialization it is better to access the ivars directoy
        
        _ID = aDictionary[@"_id"];
        _title = aDictionary[@"title"];
        _body = aDictionary[@"body"];
        _author = aDictionary[@"author"];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"_id"] = self.ID ? self.ID : [NSNull null];
    dictionary[@"title"] = self.title ? self.title : [NSNull null];
    dictionary[@"body"] = self.body ? self.body : [NSNull null];
    dictionary[@"author"] = self.author ? self.author : [NSNull null];
    return [dictionary copy];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"{\rID = %@\rtitle = %@\rbody = %@\rauthor=%@\r}",
        self.ID, self.title, self.body, self.author];
}
@end
```

Basically we're just getting values from the dictionary and setting our properties to them, and vice versa.

This means that our posts don't know anything about JSON. There's a case to be made for implementing JSON conversion directly on the Post object, but I like to work with dictionaries as an intermediate format which can be used to serialize and deserialize a post into many representations, including JSON.

The strangest thing we do is use the ternary operator to ensure that we're not adding nil to the dictionary. A dictionary cannot take a nil value but needs the placeholder [NSNull null] instead.

We also override the description function so that when we log a post to the console we see useful information.

## Posts Table View Controller

Our view controller for displaying a post is a UITableViewController subclass. In previous lessons we subclassed a normal UIViewController when working with tables, but anytime we're using a full screen table we should prefer a UITableViewController subclass. The delegate and datasource are automatically set by the storyboard and a tableView property is added which is automatically connected to the table view. 

Just make sure you're actually adding an instance of UITableViewController in your storyboard and then subclassing from that object when you create your own class.

Our table view controller keeps a posts property and returns rows, sections, and cells using it:

```obj-c
@interface PostsViewController ()

@property NSArray *posts;

@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Right bar button item
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayNewPostEditor:)];
    
    // Set up pull to refresh
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    
    // Immediately load the posts
    
    [self reloadPostsFromNetwork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network communication

- (void) reloadPostsFromNetwork {
    // ...
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.titleLabel.text = ((Post*)self.posts[indexPath.row]).title;
    cell.authorLabel.text = [((Post*)self.posts[indexPath.row]).author stringValue];
    
    return cell;
}

#pragma mark - User Actions

- (IBAction)pullToRefresh:(id)sender {
    [self reloadPostsFromNetwork];
}

- (IBAction)displayNewPostEditor:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"NewPostEditor"];
    
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
```

We're also using a custom table view cell for the Posts which offers a titleLabel and an authorLabel. They custom cell has been correctly set up in the storyboard:

```obj-c
@interface PostsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end
```

## NSURLSession

Our primary class for working with network connections is NSURLSession. An NSURLSession instance encapsulates re-usable information about network traffic, including caching policies, timeout lengths, and other configuration details. It then provides a set of methods for accomplishing network tasks using that configuration.

We'll be interested in a single task:

```obj-c
- (NSURLSessionDataTask) dataTaskWithRequest:completionHandler:
```

Because it expects HTML by default we won't actually be using this method directly. Instead I'll be providing a utility method that sets up a data task for JSON communication with a server.

Instantiating a URL Session is straightforward:

```obj-c
NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
```

## Singleton

We'll be creating a singleton object for all network communication, which will manage the session object. Rather than spreading our network code across multiple classes or implementing it in view controllers directly, we'll hang all of our network code on extensions to this singleton class.

( Recall that an extension is an addition to a class that is often defined in a separate file ) 

Our basic Client singleton is straightfoward:

**Client.h**

```obj-c
@interface Client : NSObject

@property NSURLSession *session;

+ (Client*)sharedInstance;

@end
```

All we're doing is creating a property for the session and defining a method for accessing the singleton. The implementation is also straightforward:

**Client.m**

```obj-c
#import "Client.h"

@implementation Client

+ (Client*)sharedInstance {
    static dispatch_once_t once;
    static Client *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return sharedInstance;
}

@end
```

We use grand central dispatch to ensure that the static Client shared instance is instantiated only once and return it every time. When we instantiate it, we set up the session with a default network configuration.

## GET Request

A GET HTTP request is used to retrieve data from the server. An API will typically return JSON data rather than HTML or some other format. You should strongly prefer JSON over XML for its ease of use with the Objective-C and Swift APIs.

Of course you'll actually need a server to communicate with. I'm running a simple node.js server locally that is hosting the data for this example.

**Client code**

```obj-c
- (void) GETPosts:(void (^)(id data, NSHTTPURLResponse *response, NSError *error))completionHandler {
    
    NSURLSession *session = self.session;

    NSString *host = @"http://localhost:3000";
    NSString *path = @"/api/posts";
    NSDictionary *params = @{};

    NSURL *URL = [NSURL URLWithHost:host path:path params:params];
    NSURLRequest *request = [NSURLRequest JSONRequestWithURL:URL method:@"GET" body:nil];

    NSURLSessionTask *task = [session JSONDataTaskWithRequest:request completionHandler:^(id data, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error GET /api/posts: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(data, response, error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(data, response, error);
            });
        }
    }];

    [task resume];
}
```

There's quite a bit going on here. The GETPosts: function takes a block as a callback argument. The function's network code will run asnchronously, and we need a way to communicate the network data back to the original caller when the network code is finished. Blocks are just functions and allow us to do exactly that. We can call the block function when the network code is done, passing in the data we got.

As for the network code itself, primarily we need to build an NSURLRequest for use with our utility method on NSSession, JSONRequestWithURL:method:body. This method is a wrapper for an NSURLSession data task that handles the JSON setup.

Building the URL request requires a server, a path on the server, and URL parameters, or the key-value that appear after a question mark in a URL, as in:

```
http://www.test.com?page=1&count=100
```

We have no parameters for this request.

Our JSON also takes a method type and a method body. We have a GET request and no method body. Recall that the body is the payload we want to send with the request. We'll use it in our POST request.

Finally, we build the JSON task with the data and provide an interal block callback, then fire it off with `[task resume]`. The JSON task runs asynchronously in the background, and the block is called when the task completes. If the task successfully completed, data will contain either an NSArray or NSDictionary and the error will be nil. If the task failed, error will contain some value.

The strangest bit of code here are the lines:

```obj-c
dispatch_async(dispatch_get_main_queue(), ^{
	completionHandler(data, response, error);
});
```

This is [Grand Central Dispatch](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) (GCD) code. GCD is Apple's facility for writing multithreaded applications. It provides a C level API with blocks based methods for executing code on multiple threads. You'll call a GCD method with a block, and GCD will internally set the block up to run on a separate thread.

The networking code we're using with NSURLSession runs on a background thread already. That means that our internal callback block is running in a background thread as well. We use this GCD method to call the block that the original caller provided on the main thread ( `dispatch_get_main_queue()` ).

We do this because, in a multithreaded iOS application, all changes to the interface must take place on the main thread. One way or another code in the view controller is going to need to be executed on the main thread, and rather than force the view controller to handle threading, we manage it internally from our network code.

**Using the client code**

We'll use the client code in our table view controller's reloadPostsFromNetwork. Once we've successfully retrieved and transformed the posts data we can save them to our local property and reload the table view.

```obj-c
- (void) reloadPostsFromNetwork {
    [[Client sharedInstance] GETPosts:^(id data, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error GET /api/posts: %@", error);
            // Show the user
        } else {
            NSArray *postDictionaries = (NSArray*)data;
            NSLog(@"GET /api/posts: %@", postDictionaries);
            
            NSArray *postObjects = [postDictionaries map:^id(NSDictionary *dictionary, NSUInteger index) {
                return [[Post alloc] initWithDictionary:dictionary];
            }];
            
            NSLog(@"POST OBJECTS: %@", postObjects);
            
            self.posts = postObjects;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}
```

Remember that the use of blocks here allows our code to be asynchronous. The call to GETPosts: returns immediately. The block we've provided is an anonymous function that is called on the main thread once GETPosts: has finished communicating with the server.

All we need to do is transform the data, store it, and refresh the interface.

## POST Request

A POST HTTP request is used to create a new resource on the server. You will attach a body to the request. Typically you will send JSON, which the server will deserialize and use when creating the new resource.

For our application I've added another view controller for creating a new post. We'll skip the details here and focus on the network code and how to use it.

**Client code**

```obj-c
- (void) POSTPost:(NSDictionary*)post completionHandler:(void (^)(id data, NSHTTPURLResponse *response, NSError *error))completionHandler
{
    NSURLSession *session = self.session;

    NSString *host = @"http://localhost:3000";
    NSString *path = @"/api/posts";
    
    NSDictionary *params = @{};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
    
    if ( !data ) {
        NSLog(@"Error converting post to JSON: %@", error);
        NSError *error = [[NSError alloc] initWithDomain:@"NSJSONSerialization" code:0 userInfo:nil];
        completionHandler(nil, nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithHost:host path:path params:params];
    NSURLRequest *request = [NSURLRequest JSONRequestWithURL:URL method:@"POST" body:data];

    NSURLSessionTask *task = [session JSONDataTaskWithRequest:request completionHandler:^(id data, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error POST /api/posts: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(data, response, error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(data, response, error);
            });
        }
    }];

    [task resume];
}
```

Our POST code is similar to the GET code with two major differences. The first is that it now takes a dictionary for sending over the network. This will be the dictionary representation of a post. Notice that we don't send the network method a Post instance directly. An argument can be made for this approach, but again I like to keep the code as modular as possible, so that the network code and model code doesn't know anything about each other, and let the controller mediate between the two.

A more interesting difference is the serialization of the post dictionary into is JSON representation. We use the `NSJSONSerialization` API to convert a "json object" -- that is, a dictionary or array -- into its JSON bytes, which is just the UTF-8 encoding of the json string.

After we've done that we check for errors and propogate them to the client by immediately calling the completion handler. Otherwise we set up and fire off the network call just as we did before. Notice that we set the method type to "POST" this time.

**Using the client code**

Using the client code is straightforward. We'll create a Post from a title and body, derive its dictionary representation, and then select only the key-value pairs we want to send over the network. This code is in the NewPostViewController:

```obj-c
- (IBAction)save:(id)sender {
    
    NSString *title = self.titleField.text;
    NSString *body = self.bodyView.text;
    
    // Would confirm that a title and body have been set
    
    Post *post = [[Post alloc] init];
    post.title = title;
    post.body = body;
    post.author = @(1);
    
    NSDictionary *postDictionary = [[post dictionaryRepresentation] dictionaryWithValuesForKeys:@[@"title", @"body", @"author"]];
    
    [[Client sharedInstance] POSTPost:postDictionary completionHandler:^(id data, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error saving the post");
            // Show the user
        } else {
            NSDictionary *postDictionary = (NSDictionary*)data;
            NSLog(@"%@", postDictionary);
            
            Post *post = [[Post alloc] initWithDictionary:postDictionary];
            NSLog(@"%@", post);
            
            // Would let interested parties know that a post has been created
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
```

If the post succeeds the view is dismissed. Notice that the table view doesn't refresh immediately with the new data. How might you accomplish that?

(You'll need to communicate from the new post view controller to the posts view controller that a new post has been created. There are a couple good options.)

## NSURL Utilities

Let's take a look at the utility classes I've included for communicating with an API server.

**NSURL+Params**

This category on NSURL makes it easy to create a URL with parameters, those key-value pairs that appear after the question mark in a url. Parameters must be escape encoded, and the NSURLComponents will do that for us.

```obj-c
+ (instancetype) URLWithHost:(NSString*)host path:(NSString*)path params:(NSDictionary*)params
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:[NSURL URLWithString:path relativeToURL:[NSURL URLWithString: host]] resolvingAgainstBaseURL:YES];
    
    if (params && params.count > 0) {
        NSMutableArray *queryItems = [NSMutableArray array];
        
        for ( NSString *key in params ) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:params[key]];
            [queryItems addObject:item];
        }
        
        components.queryItems = queryItems;
    }
    
    return components.URL;
}
```

**NSURLRequest+JSON**

This simple category sets up an NSURLRequest for sending and receiving JSON. We have to set headers on the HTTP request to let the server know that's what we're working with. We put this in a category because we'd have to do it everytime for any network call otherwise.

Remember, if you are repeating code, move it to a function! And move it to a category if you can.

```obj-c
+ (instancetype) JSONRequestWithURL:(NSURL*)URL method:(NSString*)method body:(NSData*)body
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    request.HTTPMethod = method;
    request.HTTPBody = body;
    
    return request;
}
```

**NSURLSession+JSONTask**

This category just wraps an NSURLSession data task and takes care of deserializing the JSON response for us. Otherwise we'd have to do it in every network call ourselves.

```objc
- (NSURLSessionTask *) JSONDataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(id data, NSHTTPURLResponse *response, NSError *error))completionHandler
{
    NSURLSessionTask *task = [self dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        id json = nil;
        if (data && !error) {
            json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
        
        completionHandler(json, (NSHTTPURLResponse*)response, error);
    }];
    
    return task;
}
```

## Additional Utilities

The project includes the NSArray+Functional_Utilities category for quickly transforming and selecting data on arrays using blocks. You'll be transforming JSON responses extensively because they always come back as NSDictionary or NSArray and you will want to convert the data to one of your model objects. The map transformation makes this easy.

**map code**

```obj-c
- (NSArray*) map:(id(^)(id obj, NSUInteger index))block
{
    NSMutableArray *results = [NSMutableArray array];
    NSUInteger i = 0;
    
    for ( id obj in self ) {
        id result = block(obj, i++);
        [results addObject:result ? result : [NSNull null]];
    }
    
    return results;
}
```

**Using map**

```obj-c
NSArray *strings = @[ @"1", @"2", @"3", @"4", @"5" ];
NSArray *numbers = [strings map:^id(id obj, NSUInteger index) {
    return @([obj integerValue]);
}];
```