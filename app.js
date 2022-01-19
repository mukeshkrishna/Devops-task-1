const express = require("express");
const http = require("http");

const app = express();

const server = http.createServer(app);

app.get('/', function(req,res){
        res.send("Hello World");
});
app.get('/health-check',(req,res)=> {
    res.send ("Health check passed");
});
app.get('/bad-health',(req,res)=> {
    res.status(500).send('Health check did not pass');
});
server.listen(3000, function(){
        console.log("Server is listening on port: 3000");
});