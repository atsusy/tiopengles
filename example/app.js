// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'#411'
});

// TODO: write your module tests here
var opengles = require('com.tiopengles');
var openglesView = opengles.createView({
	zNear:0.01,
	zFar:1000.0,
	fieldOfView:45.0,
	userDepthBuffer:true,
	lights: [ { ambient:{r:0.6,g:0.2,b:0.2}, 
			    diffuse:{r:0.7,g:0.3,b:0.3}, 
			   specular:{r:0.7,g:0.3,b:0.3},
			   position:{x:5.0,y:5.0,z:5.0}} ]
});

var cube1 = opengles.load3ds("cube.3ds");
cube1.rotation({x:45.0,y:0.0,z:0.0});
cube1.translation({x:0.0,y:0.0,z:-10.0});
openglesView.addModel(cube1);

var cube2 = opengles.load3ds("cube.3ds");
cube2.rotation({x:45.0,y:0.0,z:45.0});
cube2.translation({x:3.0,y:3.0,z:-20.0});
openglesView.addModel(cube2);

window.add(openglesView);
window.open();