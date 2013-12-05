// controls buttons and other inputs used on the code page (sends data to pde files)

function goRet(id) {
	var pjs = Processing.getInstanceById(id);
	var pts = pjs.go();
	document.getElementById("results").innerHTML = "Points: " + pts;
}

function nextStepRet(id) {
	var pjs = Processing.getInstanceById(id);
	var pts = pjs.step();
	document.getElementById("results").innerHTML = "Points: " + pts;
}

function go(id) { Processing.getInstanceById(id).go(); }

function nextStep(id) { Processing.getInstanceById(id).step(); }

function reset(id) { Processing.getInstanceById(id).setup(); }

function debug(id) { Processing.getInstanceById(id).toggleDebug(); }
