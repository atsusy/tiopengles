// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'#222'
});

// TODO: write your module tests here
var opengles = require('com.tiopengles');

var camera = opengles.createCamera({
	position:{x:0.0,y:30.0,z:500.0}, 
	angle:{x:0.0,y:0.0,z:0.0}
});

var view = opengles.createView({
	zNear:5.0,
	zFar:1000.0,
	fieldOfView:45.0,
	depthBuffer:true,
	lights:[ { ambient:{r:0.2,g:0.2,b:0.2}, 
			   diffuse:{r:0.5,g:0.5,b:0.5}, 
			  specular:{r:0.8,g:0.8,b:0.8},
			  position:{x:100.0,y:100.0,z:100.0} } ],
	camera:camera
});

var touchmove_x, touchmove_y;
view.addEventListener('touchmove', function(e){
	if(touchmove_x && touchmove_y){
		var delta_x = e.x - touchmove_x;
		var delta_y = e.y - touchmove_y;
		camera.yaw(delta_x / 10.0);
		camera.pitch(delta_y / 10.0);
	}
	touchmove_x = e.x;
	touchmove_y = e.y;
});
window.add(view);	

view.addEventListener('touchend', function(e){
	touchmove_x = undefined;
	touchmove_y = undefined;
});

var r2d2 = opengles.load3ds('modules/com.tiopengles/r2d2/r2d2.3ds');
r2d2.rotation({x:-90.0,y:0.0,z:0.0});
r2d2.translation({x:0.0,y:40.0,z:0.0});
view.addModel(r2d2);

var pressing = {up:false, down:false, left:false, right:false, forward:false, back:false};

var up = Ti.UI.createButton({
	left:52,
	bottom:48*2,
	width:90,
	height:42,
	opacity:0.4,
	title:'Up'
});

up.addEventListener('touchstart',function(e){
	pressing.up = true;
});
up.addEventListener('touchend',function(e){
	pressing.up = false;
});
window.add(up);

var down = Ti.UI.createButton({
	left:52,
	bottom:0,
	width:90,
	height:42,
	opacity:0.4,
	title:'Down'
});
down.addEventListener('touchstart',function(e){
	pressing.down = true;
});
down.addEventListener('touchend',function(e){
	pressing.down = false;
});

window.add(down);
var right = Ti.UI.createButton({
	left:48*2+4,
	bottom:48,
	width:90,
	height:42,
	opacity:0.4,
	title:'Right'
});
right.addEventListener('touchstart',function(e){
	pressing.right = true;
});
right.addEventListener('touchend',function(e){
	pressing.right = false;
});
window.add(right);
var left = Ti.UI.createButton({
	left:4,
	bottom:48,
	width:90,
	height:42,
	opacity:0.4,
	title:'Left'
});
left.addEventListener('touchstart',function(e){
	pressing.left = true;
});
left.addEventListener('touchend',function(e){
	pressing.left = false;
});
window.add(left);

var forward = Ti.UI.createButton({
	right:12,
	bottom:72,
	width:110,
	height:48,
	opacity:0.4,
	title:'Forward'
});
window.add(forward);
forward.addEventListener('touchstart', function(e){
	pressing.forward = true;
});
forward.addEventListener('touchend', function(e){
	pressing.forward = false;
});

var back = Ti.UI.createButton({
	right:12,
	bottom:12,
	width:110,
	height:48,
	opacity:0.4,
	title:'Back'
});
window.add(back);
back.addEventListener('touchstart', function(e){
	pressing.back = true;
});
back.addEventListener('touchend', function(e){
	pressing.back = false;
});

setInterval(function(){
	var vec = {x:0.0, y:0.0, z:0.0};
	if(pressing.up){
		vec.y = 10.0;
	}
	if(pressing.down){
		vec.y = -10.0;
	}
	if(pressing.right){
		vec.x = 10.0;
	}
	if(pressing.left){
		vec.x = -10.0;
	}
	if(pressing.forward){
		vec.z = -10.0;
	}
	if(pressing.back){
		vec.z = 10.0;
	}
	camera.move(vec);
}, 100);

window.open();