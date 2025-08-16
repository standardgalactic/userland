<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>3D Vim Space Exploration Game</title>
  <link rel="stylesheet" href="css/style.css"/>
  <link rel="stylesheet" href="js/vendor/codemirror.css"/>
</head>
<body>
  <div id="editor-container" style="display:none;"></div>
  <div id="command-input" style="position:absolute;bottom:10px;left:10px;color:white;">Command: </div>
  <div id="score" style="position:absolute;top:10px;right:10px;color:white;">Score: 0</div>

  <!-- Use local vendor JS -->
  <script src="js/vendor/three.min.js"></script>
  <script src="js/vendor/OrbitControls.js"></script>
  <script src="js/vendor/codemirror.min.js"></script>
  <script src="js/vendor/vim.min.js"></script>

  <!-- Do NOT include commands.json as a <script>; you already fetch it in JS -->
  <!-- <script src="js/commands.json" type="application/json"></script>  <-- remove -->

  <!-- Your game scripts -->
  <script src="js/skillTracker.js"></script>
  <script src="js/galaxyMap.js"></script>
  <script src="js/bubbleShooter.js"></script>
  <script src="js/vimPuzzle.js"></script>
  <script src="js/main.js"></script>
</body>
</html>

