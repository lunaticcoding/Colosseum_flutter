/* TODO for control with push ups later on
  function pull() {
    var result=JSON.parse(PUHS_UP_CONTROLLER.getLux());
    update_lux(result.lux);
  }
*/
var yVelocity;
var obstacleSpeed;
var obstacles = [];
var horizon;
var tRexY;
var onGround;
var score;
var lastObstacleCreated;
var lives;
var liveLostTime;
var isGameStarted = false;


function startGame() {
	isGameStarted = true;
}

function setup() {
	createCanvas(window.innerWidth,window.innerHeight);

	horizon = height-40;
	yVelocity = 0;
	tRexY = 20;
	obstacleSpeed = 2.5;
	onGround = false;
	score = 0;
	textAlign(CENTER);
	lastObstacleCreated = Date.now();
	liveLostTime = Date.now();
	lives = 3;

}

function draw() {
//	if(isGameStarted){
    if(true) {
		background(51);

		stroke(255);
		line(0, horizon, width, horizon);

		fill('#FF00FF');
		ellipse(40, tRexY, 40);

		if(frameCount%360 === 0){
			obstacleSpeed *= 1.05;
			if(obstacleSpeed>2.5) {obstacleSpeed=4;}
		}

		if(frameCount%10 === 0){
			var n = random(0, 1);
			if(n > 0.5){
				if(Date.now()-lastObstacleCreated>2000){

				lastObstacleCreated=Date.now();
				newObstacle();
				}
			}
		}

		updateObstacles();
		handleTRex();

		score++;
		textSize(20);
		text("Score: " + score, width/2, 30);
		text("Lives: " + lives, width/4, 30);
	}
}

function newObstacle() {
	var obs = new Obstacle(random(20, 35), color(random(255), random(255), random(255)));
	obstacles.push(obs);
}

function updateObstacles() {
	for(var i=obstacles.length-1; i >= 0; i--) {
		obstacles[i].x -= obstacleSpeed;

		var x = obstacles[i].x;
		var size = obstacles[i].size;

		if(x > -30) {
			fill(obstacles[i].color);
			rect(x, horizon-size, size, size);
			var x1 = x+size/2;
			var y1 = horizon - size/2;
			if(dist(x1, y1, 40, tRexY) < size/2 + 20 && Date.now()-liveLostTime>2000) {
				// collision
				liveLostTime=Date.now();
				lives--;
				if(lives<1){
					noStroke();
					textSize(40);
					text("GAME OVER", width/2, height/2);
					noLoop();
				}
			} 
		} else {
			obstacles.splice(i, 1);
		}
	}
}

function isGameOver() {
    return lives < 1;
}

function controller(value) {
	//if(keyIsDown(UP_ARROW) || keyIsDown(32) || mouseIsPressed) {
		if(onGround){
			yVelocity -= 8;
			onGround = false;
	}
}

function handleTRex(){
	if((tRexY + 20 + yVelocity) < horizon) {
		yVelocity += 0.25;
		onGround = false;
	} else {
		yVelocity = 0;
		onGround = true;
	}

	tRexY+=yVelocity;
}
