loadCordova = ->
  if navigator.userAgent.indexOf("Android") > 0
    $(document.createElement("script")).attr("src", "./cordova-android.js").appendTo "head"
  else if navigator.userAgent.indexOf("iPhone") > 0 or navigator.userAgent.indexOf("iPad") > 0 or navigator.userAgent.indexOf("iPod") > 0
    $(document.createElement("script")).attr("src", "./cordova-ios.js").appendTo "head"
