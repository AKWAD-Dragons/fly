# Fly
#### An API Manager used to facilitate sending API requests and parse the response
### Usage
To use this plugin, add `fly_networking` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
### Example
    import  'package:Fly/fly.dart';
    
    // To edit and manipulate data
    Map result = await fly.mutation(//Request parametes);
    
    // To query for data
    Map result = await fly.query(//Request parametes);

### Request Parameters

 1. Node
 Contains the piece of data that need to be manipulated or queried , consists of the node name , arguments for mutations and cols
 E.g : Node(name"profile", args : {"id":1} ,cols:["id" , "name" , "email"])
 
 2. Parsers
 A map contains the needed data to parse the received response
 
### Complete example

    //Query example
    Node node = Node(name: 'profile', cols: ["name" , "email"]);
    Map result = await fly.query([node], parsers: {"profile": 
    User.empty()});
    User user = result['profile'];

    //Mutation Example
    Node node = Node(name: 'updateProfile', args:{
    "id":"1",
    "name":"John Doe",
    "email":"johndoe@example.com"
    },cols: ["name" , "email"]);
    Map result = await fly.mutation([node], parsers: {"updateProfile": 
    User.empty()});
    User user = result['updateProfile'];
