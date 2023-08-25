// Copyright (C) Microsoft. All rights reserved.

//*******************************************************************
// Global variables

// Mock this for testing in the browser
if (!window.WinGS) {
    window.WinGS = {
        logBI: function () { },
        navigateEvent: function () { }
};
}

if (!window.RDX) {
    window.RDX = {
        logBI: function () { },
        navigateEvent: function () { }
};
}

// Reset the UI to the initial state
function reset() {
    home();
}

function home() {
    goToArbitrarySection(0);
}

// Slider Div
var slider = document.getElementById('slider');
var sliderElementStyles = slider.style;
slider.style.position = "absolute";
slider.style.left = "0px";
slider.style.width = "100%";
slider.style.tranform = "translateX(0)";
slider.parentElement.style.position = "relative";
// Revisit: Make sure the flippers stay above the the slider (which for some reason is on top in the HTML)
var carouselControls = document.body.querySelector(".carousel-controls");
if (carouselControls) {
    carouselControls.style.zIndex = "2";
}

var currentlyShowingSlide;
var currentlyShowingSlideID;
var leftSideID = "";
var rightSideID = "";

// Will be minified eventually
var rightString = "right";
var leftString = "left";
var MsGrid = "-ms-grid";
var None = "none";


var buildingJustOneSide = false;
var buildJustThisSide = "";

// Array of Slide IDs info
var arrayOfSlideIDsLength;
var lastSlideIDin_ArrayOfSlideIDs;
var secondToLastSlideIDin_ArrayOfSlideIDs;

var carouselWidth;
var thePointerType;
var directionSliderMoving = "";

var sliderTransitionSpeed = "1s";
var sliderTransitionSpeedTimeout = 1050;

var buildLandRExecuted = false;
var buildExecuted = false;

var built_slide_margin_left = "";
var builtOffSCreenOnThisSide = "";

var pixelWidth = 0;
var pixelWidthPxString = "";
var negPixelWidthPxString = "";
// Variables used in moving() & end()
var InitialXPoint;
var oneFifthOriginalCarouselWidth;
var movedX = 0;

// goForwardOrBack() Variables
var currentlyShowingPageIDIndex;

var increaseFlipperZIndexFired = false;

// Locks
var isBuilt = false;
var isAnimating = false;
var pointerType;

// Variables generated on window.load by generateArraysOfSlideIDs()
var arrayOfSlideIDs = [];
var arrayOfSections = [];
var lastSection;

//*******************************************************************
// Carousel state

var currentSection = 0;
var currentPage = 0;
var pageCounts = [];

//Track links inside content"
(function linkTracker() {
    var forEach = Array.prototype.forEach;
    var links = document.getElementsByTagName('a');

    forEach.call(links, function (link) {
        if (link.parentNode.classList.contains('content') || link.parentNode.classList.contains('main-content')) {
            link.onclick = function (event) {
                WinGS.logBI("Click", "{'target':'" + link + "','text':'" + event.target.innerHTML + "','page':'" + currentID() + "'}");
            }
        }
    });
})();

function currentID() {
    return currentSection.toString() + "-" + currentPage.toString();
}

function setActivePageIndicator() {
    var pageIndicators = document.getElementsByClassName("layoutRoot-indicatorContainer");
    for (var i = 0; i < pageIndicators.length; i++) {
        if (i === currentPage) {
            pageIndicators[i].firstElementChild.classList.add("active");
        } else {
            pageIndicators[i].firstElementChild.classList.remove("active");
        }
    }
}

function onSectionChange() {
    setActiveHubButton();

    var pageIndicators = document.getElementsByClassName("layoutRoot-indicatorContainer");
    for (var i = 0; i < pageIndicators.length; i++) {
        if (pageCounts[currentSection] === 1) {
            // Hide page indicators if there's only one page
            pageIndicators[i].style.display = None;
        } else if (i < pageCounts[currentSection]) {
            // Indicator divs have the class indicator-{{value:sectionId}}
            pageIndicators[i].firstElementChild.className = "indicatorContainer-indicator indicator-" + currentSection;
            pageIndicators[i].style.display = "inline-block";
        } else {
            pageIndicators[i].style.display = None;
        }
    }
}

function setActiveHubButton() {
    var hubButtons = document.getElementsByClassName("template-hubButton");
    for (var i = 0; i < hubButtons.length; i++) {
        if (i === currentSection) {
            hubButtons[i].classList.add("active");
        } else {
            hubButtons[i].classList.remove("active");
        }
    }
}

function pauseOrPlayVideos() {
    let videos = document.getElementsByTagName("video");
    for (let i = 0; i < videos.length; i++) {
        let vid = videos[i];
        if (vid.offsetWidth == 0) { // Indicates an ancestor is set to display:none
            vid.pause();
        }
        else {
            vid.play();
        }
    }
};

// There's no "pause" for animated GIFs, but they use CPU (and progress through the sequence) even when off-screen.
// To stop this, we remove their src property when off-screen.
// We do this earlier in slide transitions than pauseOrPlayVideos 
// because we want the actual image size used correctly for layout purposes.
function pauseOrPlayGIFs() {
    let images = document.getElementsByTagName("img");
    for (let i = 0; i < images.length; i++) {
        let img = images[i];
        if (img.offsetWidth == 0) { // Indicates an ancestor is set to display:none
            let src = img.getAttribute("src");
            if (src && src.toLowerCase().indexOf(".gif") > 0) {
                img.removeAttribute("src");
            }
        }
        else if (img.hasAttribute("data-original-src")) {
            img.src = img.getAttribute("data-original-src");
        }
    }
}

function storeImgSources() {
    let images = document.getElementsByTagName("img");
    for (let i = 0; i < images.length; i++) {
        let img = images[i];
        let src = img.getAttribute("src");
        if (src && src.toLowerCase().indexOf(".gif") > 0) {
            img.setAttribute("data-original-src", src);
        }
    }
}

//*******************************************************************

function reCentering(eventHappening) {
    directionSliderMoving = "neither";
    sliderElementStyles.transition = sliderTransitionSpeed;
    if (buildLandRExecuted === true) {
        sliderElementStyles.transform = "translateX(-100%)";
    } else if (buildExecuted === true) {
        if (builtOffSCreenOnThisSide === rightString) {
            sliderElementStyles.transform = "translateX(0px)";
        } else {
            sliderElementStyles.transform = "translateX(100%)";
        };
    };
};

function updatePage(num) {
    if (num === 1) {
        if (++currentPage === pageCounts[currentSection]) {
            currentPage = 0;
            if (++currentSection === pageCounts.length) {
                currentSection = 0;
            };
            onSectionChange();
        };
        setActivePageIndicator();
    } else if (num === -1) {
        if (--currentPage === -1) {
            if (--currentSection < 0) {
                currentSection = pageCounts.length - 1;
                currentPage = pageCounts[currentSection] - 1;
            } else {
                currentPage = pageCounts[currentSection] - 1;
            }
            onSectionChange();
        } else {
        }
        setActivePageIndicator();
    } else {
    };
};

function generateArraysOfSlideIDs() {
    var sliderParentDiv = document.getElementById("slider");
    var sliderDivChildren = sliderParentDiv.getElementsByTagName("div");
    for (i = 0; i < sliderDivChildren.length; i++) {
        if (sliderDivChildren[i].parentNode === sliderParentDiv) {
            arrayOfSlideIDs.push(sliderDivChildren[i].id);
        };
    };
    for (var i = 0; i < arrayOfSlideIDs.length; i++) {
        var arrayOfSectionsIndex = arrayOfSections.length - 1;
        var currentArraySection = parseInt(arrayOfSlideIDs[i].slice(0, 1));
        if (currentArraySection <= arrayOfSections[arrayOfSectionsIndex]) {
            // do nothing
        } else {
            arrayOfSections.push(currentArraySection);
        };
    };
    lastSection = arrayOfSections[(arrayOfSections.length - 1)];
    arrayOfSlideIDsLength = arrayOfSlideIDs.length;
    lastSlideIDin_ArrayOfSlideIDs = arrayOfSlideIDs[(arrayOfSlideIDsLength - 1)];
    secondToLastSlideIDin_ArrayOfSlideIDs = arrayOfSlideIDs[(arrayOfSlideIDsLength - 2)];
};

//*******************************************************************
// window.OnLoad

window.addEventListener('DOMContentLoaded', function () {
    generateArraysOfSlideIDs();
    storeImgSources();
    pauseOrPlayVideos();
    pauseOrPlayGIFs();
    if (document.getElementsByClassName("mobileSlider").length === 0) {
        slider.addEventListener('pointerdown', function (e) {
            if (e.pointerType == "touch") {
                begin(e);
                e.preventDefault();
            }
        }, false)
        slider.addEventListener('pointermove', function (e) {
            if (e.pointerType == "touch") {
                moving(e);
                e.preventDefault();
            }
        }, false)
        slider.addEventListener('pointerup', function (e) {
            if (e.pointerType == "touch") {
                end(e);
                e.preventDefault();
            }
        }, false)
    }
}, false)

//*******************************************************************
// begin

var begin = function (event) {
    if (event.isPrimary === true) {
        pointerType = event.pointerType;
        if (!isBuilt && isAnimating === false) {
            isBuilt = true;
            carouselWidth = slider.clientWidth;
            determingShowingSlide();
            determineLandR(currentlyShowingSlideID);
            buildLandR(leftSideID, rightSideID, currentlyShowingSlideID);
        };
    };
};

//*******************************************************************
// begin RELATED FUNCTIONS

function build(onThisSide, offScreenSlideID, showingSlideID) {
    var showingSlideIDStyles = document.getElementById(showingSlideID).style;
    sliderElementStyles.transition = "all";
    builtOffSCreenOnThisSide = onThisSide;
    buildExecuted = true;
    buildingJustOneSide = true;
    buildJustThisSide = onThisSide;
    if (onThisSide === rightString) {
        var sideOfScreenWithNoSlide = leftString;
    } else {
        var sideOfScreenWithNoSlide = rightString;
        sliderElementStyles.transform = "translateX(-100%)";
    };
    setShowingSlideToClientWidth(showingSlideID);
    if (showingSlideID === arrayOfSlideIDs[0] && onThisSide === leftString) {
        showingSlidePositionAndSliderWidth();
        showingSlideIDStyles.left = "100%";
        fabricate([offScreenSlideID, onThisSide]);
    } else if (showingSlideID === lastSlideIDin_ArrayOfSlideIDs && onThisSide === rightString) {
        showingSlidePositionAndSliderWidth();
        showingSlideIDStyles.left = '';
        var firstSlideStyles = document.getElementById(arrayOfSlideIDs[0]).style;
        firstSlideStyles.position = 'absolute';
        firstSlideStyles.left = '100%';
        firstSlideStyles.display = MsGrid;
    } else {
        showingSlideIDStyles.float = sideOfScreenWithNoSlide;
        fabricate([offScreenSlideID, onThisSide]);
    };
    function showingSlidePositionAndSliderWidth() {
        showingSlideIDStyles.position = "absolute";
    };
    pauseOrPlayGIFs();
};

function buildLandR(left, right, showing) {
    buildLandRExecuted = true;
    var rightNowShowingIDStyles = document.getElementById(showing).style;
    sliderElementStyles.transition = "all";
    rightNowShowingIDStyles.transition = "all";
    rightNowShowingIDStyles.display = MsGrid;
    rightNowShowingIDStyles.margin = "0 auto";
    setShowingSlideToClientWidth(showing);
    sliderElementStyles.transform = "translateX(-100%)";
    rightNowShowingIDStyles.margin = "";
    if (currentlyShowingSlideID === arrayOfSlideIDs[0] || currentlyShowingSlideID === lastSlideIDin_ArrayOfSlideIDs) {
        rightNowShowingIDStyles.position = "absolute";
        fabricateFirstAndLast_LandR(left, right);
        rightNowShowingIDStyles.left = "100%";
        increaseFlipperZIndex();
    } else {
        rightNowShowingIDStyles.left = pixelWidthPxString;
        fabricate([left, leftString], [right, rightString]);
        rightNowShowingIDStyles.left = "";
    };
    pauseOrPlayGIFs();
};

/////////////////////////////////
// increaseFlipperZIndex() and resetFlipperZIndex() are needed 
// to get flippers to display on First and Last slide, since since the touch transitions 
// for those slides use different positioning JS than the others
function increaseFlipperZIndex() {
    increaseFlipperZIndexFired = true;
    var hubButtons = document.getElementsByClassName("template-hubButton");
    for (var i = hubButtons.length - 1; i >= 0; i--) {
        hubButtons[i].style.zIndex = "5";
    };
    var rightFlipper = document.querySelector(".rightNav");
    var leftFLipper = document.querySelector(".leftNav");
    rightFlipper.style.zIndex = "2";
    leftFLipper.style.zIndex = "2";
};

function resetFlipperZIndex() {
    increaseFlipperZIndexFired = false;
    var hubButtons = document.getElementsByClassName("template-hubButton");
    for (var i = hubButtons.length - 1; i >= 0; i--) {
        hubButtons[i].style.zIndex = "";
    };
    var rightFlipper = document.querySelector(".rightNav");
    var leftFLipper = document.querySelector(".leftNav");
    rightFlipper.style.zIndex = "";
    leftFLipper.style.zIndex = "";
};

/////////////////////////////////

function determingShowingSlide() {
    for (var i = 0; i < arrayOfSlideIDs.length; i++) {
        if (document.getElementById(arrayOfSlideIDs[i]).style.display === MsGrid) {
            currentlyShowingSlide = document.getElementById(arrayOfSlideIDs[i]);
            currentlyShowingSlideID = arrayOfSlideIDs[i];
        };
    };
};

function determineLandR(currentSlideID) {
    if (currentlyShowingSlideID === arrayOfSlideIDs[0]) {
        leftSideID = lastSlideIDin_ArrayOfSlideIDs;
        rightSideID = arrayOfSlideIDs[1];
    } else if (currentlyShowingSlideID === lastSlideIDin_ArrayOfSlideIDs) {
        leftSideID = secondToLastSlideIDin_ArrayOfSlideIDs;
        rightSideID = arrayOfSlideIDs[0];
    } else {
        for (var i = 0; i < arrayOfSlideIDs.length; i++) {
            if (currentlyShowingSlideID === arrayOfSlideIDs[i]) {
                leftSideID = arrayOfSlideIDs[i - 1];
                rightSideID = arrayOfSlideIDs[i + 1];
            };
        };
    };
};

function fabricateFirstAndLast_LandR(left, right) {
    var leftStyles = document.getElementById(left).style;
    var rightStyles = document.getElementById(right).style;
    leftStyles.transition = "all";
    rightStyles.transition = "all";
    rightStyles.left = "200%";
    absoluteAndNoFloat(rightStyles, leftStyles);
    leftStyles.display = MsGrid;
    rightStyles.display = MsGrid;
    function absoluteAndNoFloat() {
        for (var i = 0; i < arguments.length; i++) {
            arguments[i].float = "";
            arguments[i].position = 'absolute';
        };
    };
};

function fabricate() {
    // [SlideIDstring, floatSide]
    // Example:   fabricate([left,leftString],[right,rightString]);
    for (var i = 0; i < arguments.length; i++) {
        document.getElementById(arguments[i][0]).style.float = arguments[i][1];
        document.getElementById(arguments[i][0]).style.display = MsGrid;
    };
};

function setShowingSlideToClientWidth(showingSlideID) {
    pixelWidth = document.getElementById(showingSlideID).clientWidth;
    pixelWidthPxString = pixelWidth.toString() + "px";
    negPixelWidthPxString = "-" + pixelWidth.toString() + "px";
    document.getElementById(showingSlideID).style.width = pixelWidthPxString;
};

//*******************************************************************
// moving

var moving = function (event) {
    if (event.isPrimary === true &&
      pointerType === event.pointerType &&
      isAnimating === false &&
      isBuilt === true) {
        var midX = event.clientX;
        var movedX = 0;
        var absoluteDiffrerence = Math.abs(Math.abs(InitialXPoint) - Math.abs(midX));
        var difference = Math.abs(InitialXPoint) - Math.abs(midX);
        if (InitialXPoint === undefined) {
            InitialXPoint = midX;
        } else {
            movedX = midX - InitialXPoint;
        };
        sliderElementStyles.transition = "none";
        movedX = movedX - carouselWidth;
        sliderElementStyles.transform = "translateX(" + movedX.toString() + "px)";
        oneFifthOriginalCarouselWidth = (carouselWidth / 5);
        if (absoluteDiffrerence > oneFifthOriginalCarouselWidth && difference > 0) {
            isAnimating = true;
            var oldPage = currentID();
            updatePage(1);
            WinGS.logBI("Swipe", "{'direction':'previous','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
            slideSlider(leftString);
        } else if (absoluteDiffrerence > oneFifthOriginalCarouselWidth && difference < 0) {
            isAnimating = true;
            var oldPage = currentID();
            updatePage(-1);
            WinGS.logBI("Swipe", "{'direction':'next','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
            slideSlider(rightString);
        };
    };
};

//*******************************************************************
// end

var end = function (event) {
    if (event.isPrimary === true) {
        if (!isAnimating) {
            isAnimating = true;
            reCentering(event);
            isAnimating = false;
            InitialXPoint = undefined;
        };
    };
};

//*******************************************************************
// sliding

function slideSlider(directionMoving) {
    sliderElementStyles.transition = sliderTransitionSpeed;
    if (directionMoving === rightString) {
        directionSliderMoving = rightString;
        sliderElementStyles.transform = "translateX(0px)";
    } else if (directionMoving === leftString && buildingJustOneSide === true) {
        directionSliderMoving = leftString;
        sliderElementStyles.transform = "translateX(-100%)";
    } else if (directionMoving === leftString) {
        directionSliderMoving = leftString;
        sliderElementStyles.transform = "translateX(-200%)";
    };

    // Move page indicators to bottom for specs page
    var target;
    if (directionMoving === rightString) {
        target = document.getElementById(leftSideID);
    } else {
        target = document.getElementById(rightSideID);
    }
    if (target.classList.contains("contentCard-specs")) {
        document.getElementsByClassName("template-pageIndicator")[0].classList.add("indicators-bottom");
    } else {
        document.getElementsByClassName("template-pageIndicator")[0].classList.remove("indicators-bottom");
    }
    setTimeout(function () {
        disassemble();
        isAnimating = false;
        isBuilt = false;
    }, sliderTransitionSpeedTimeout);
};

//*******************************************************************
// disassemble AND hiding functions

function disassemble() {
    var directionSliderMoved = directionSliderMoving;
    sliderElementStyles.transition = "all";
    InitialXPoint = undefined;
    if (increaseFlipperZIndexFired) {
        resetFlipperZIndex();
    };
    if (directionSliderMoved === "neither" || directionSliderMoved === undefined) {
        hideTwoSlides("both");
    } else if (buildingJustOneSide === true && buildJustThisSide === rightString) {
        hideOneSlide(leftString, true);
    } else if (buildingJustOneSide === true && buildJustThisSide === leftString) {
        hideOneSlide(rightString, true);
    } else if (buildingJustOneSide !== true && directionSliderMoved === leftString) {
        hideTwoSlides(leftString);
    } else if (buildingJustOneSide !== true && directionSliderMoved === rightString) {
        hideTwoSlides(rightString);
    };
    pauseOrPlayVideos();
    pauseOrPlayGIFs();
};

function hideOneSlide(onThisSide, hasSlideExecuted) {
    buildingJustOneSide = false;
    if (onThisSide === rightString && hasSlideExecuted === true) {
        hiding(currentlyShowingSlideID, leftSideID);
    } else if (onThisSide === rightString && hasSlideExecuted === false) {
        hiding(leftSideID, currentlyShowingSlideID);
    } else if (onThisSide === leftString && hasSlideExecuted === true) {
        hiding(currentlyShowingSlideID, rightSideID);
    } else if (onThisSide === leftString && hasSlideExecuted === false) {
        hiding(rightSideID, currentlyShowingSlideID);
    };
};

function hiding(hiding, visible) {
    document.getElementById(visible).style.width = "100%";
    dissapearUnusedSlides_UnFloatCenter_reSetSlider(visible, [hiding]);
    resetCurrentlyShowingSlides(visible);
    resetBooleansAndLogicValues();
};

function hideTwoSlides(onThisSide) {
    sliderElementStyles.transition = "all";
    if (onThisSide === leftString) {
        dissapearUnusedSlides_UnFloatCenter_reSetSlider(rightSideID, [leftSideID, currentlyShowingSlideID]);
        resetCurrentlyShowingSlides(rightSideID);
        resetBooleansAndLogicValues();
    } else if (onThisSide === rightString) {
        dissapearUnusedSlides_UnFloatCenter_reSetSlider(leftSideID, [rightSideID, currentlyShowingSlideID]);
        resetCurrentlyShowingSlides(leftSideID);
        resetBooleansAndLogicValues();
    } else if (onThisSide === "both") {
        leaveCenterVisibleMargin();
        dissapearUnusedSlides_UnFloatCenter_reSetSlider(currentlyShowingSlideID, [rightSideID, leftSideID]);
        resetCurrentlyShowingSlides(currentlyShowingSlideID);
        resetBooleansAndLogicValues();
    };
};

function dissapearUnusedSlides_UnFloatCenter_reSetSlider(slideIDCSSfloattoEmptyString, arrayOfSlideIDsToVanish) {
    var aSlideToReset = document.getElementById(slideIDCSSfloattoEmptyString).style;
    aSlideToReset.float = "";
    aSlideToReset.position = "static";
    aSlideToReset.left = "";
    for (var i = 0; i < arrayOfSlideIDsToVanish.length; i++) {
        if (arrayOfSlideIDsToVanish[i].length > 1) {
            var slideToStyle = document.getElementById(arrayOfSlideIDsToVanish[i]).style;
            slideToStyle.display = None;
            slideToStyle.float = "";
            slideToStyle.position = "static";
            slideToStyle.left = "0px";
        };
    };
    sliderWidthAndMarginReSet();
};

function resetCurrentlyShowingSlides(NEWcurrentlyShowingSlideID) {
    currentlyShowingSlide = document.getElementById(NEWcurrentlyShowingSlideID);
    currentlyShowingSlideID = NEWcurrentlyShowingSlideID;
};

function sliderWidthAndMarginReSet() {
    sliderElementStyles.transform = "translateX(0px)";
    sliderElementStyles.width = "100%";
};

function leaveCenterVisibleMargin() {
    sliderElementStyles.transform = "translateX(-100%)";
};

function resetBooleansAndLogicValues() {
    buildLandRExecuted = false;
    buildExecuted = false;
};

//*******************************************************************
// section sliding
//  possible bug - will there ever be only 1 section?

// Fired ONLY on initial page load at 5000 millisecond intervals 
var isNewSlideToNextSectionRightExecuting = false;

function newSlideToNextSectionRight() {
    var isNextSectionHigher = false;
    isNewSlideToNextSectionRightExecuting = true;
    var nextSection = currentSection;
    nextSection = nextSection + 1;
    for (var i = 0; i < arrayOfSections.length; i++) {
        if (nextSection === arrayOfSections[i]) {
            isNextSectionHigher = true;
            goToArbitrarySection(nextSection);
        };
    };
    if (isNextSectionHigher === false) {
        goToArbitrarySection(0);
    };
    isNextSectionHigher = false;
};


//*******************************************************************
// huButton & dot-indicator functions

function goToArbitrarySection(sectionNumber) {
    if (!isAnimating) {
        isAnimating = true;
        ifIsBuiltIsTrue_Dissassemble();
        determingShowingSlide();
        if (currentSection !== sectionNumber) {
            var firstSlideOfSectionToGoTo = sectionNumber.toString() + "-0";
            determingShowingSlide();
            if (currentSection < sectionNumber || isNewSlideToNextSectionRightExecuting) {
                rightSideID = firstSlideOfSectionToGoTo;
                build(rightString, firstSlideOfSectionToGoTo, currentlyShowingSlideID);
                slideSlider(leftString);

                isNewSlideToNextSectionRightExecuting = false;
            } else { // currentSection > sectionNumber
                leftSideID = firstSlideOfSectionToGoTo;
                build(leftString, firstSlideOfSectionToGoTo, currentlyShowingSlideID);
                slideSlider(rightString);

            };
            executeUpdatePage(currentlyShowingSlideID, firstSlideOfSectionToGoTo);
        } else {
            isAnimating = false;
        };
        isNextSectionActuallyAHigherInt = false;
    };
};

function goToArbitraryPage(page) {
    if (!isAnimating) {
        isAnimating = true;
        ifIsBuiltIsTrue_Dissassemble();
        determingShowingSlide();
        var slideIDNavigatingTo = currentSection.toString() + "-" + page.toString();
        if (currentPage === page) {
            isAnimating = false;
        } else if (currentPage < page) {
            rightSideID = slideIDNavigatingTo;
            build(rightString, slideIDNavigatingTo, currentlyShowingSlideID);
            slideSlider(leftString);
        } else { // currentPage > page
            leftSideID = slideIDNavigatingTo;
            build(leftString, slideIDNavigatingTo, currentlyShowingSlideID);
            slideSlider(rightString);
        };
        executeUpdatePage(currentlyShowingSlideID, slideIDNavigatingTo);
    };
};

function executeUpdatePage(showingSlideID, slideComingInID) {
    var showingSlideIDIndex
    var slideComingInIDIndex
    for (var i = 0; i < arrayOfSlideIDs.length; i++) {
        if (arrayOfSlideIDs[i] === showingSlideID) {
            showingSlideIDIndex = i;
        } else if (arrayOfSlideIDs[i] === slideComingInID) {
            slideComingInIDIndex = i;
        };
    };
    var difference = showingSlideIDIndex - slideComingInIDIndex;
    var absDifference = Math.abs(difference);
    if (difference > 0) {
        while (difference--) {
            updatePage(-1);
        };
    } else { // difference < 0
        while (absDifference--) {
            updatePage(1);
        };
    };
};

//*******************************************************************
// L&R FLIPPER FUNCTIONS

function toTheNextPage() {
    if (!isAnimating) {
        isAnimating = true;
        ifIsBuiltIsTrue_Dissassemble();
        determingShowingSlide();
        determineLandR(currentlyShowingSlideID);
        updatePage(1);
        build(rightString, rightSideID, currentlyShowingSlideID);
        slideSlider(leftString);
    };
};

function toThePreviousPage() {
    if (!isAnimating) {
        isAnimating = true;
        ifIsBuiltIsTrue_Dissassemble();
        determingShowingSlide();
        determineLandR(currentlyShowingSlideID);
        updatePage(-1);
        build(leftString, leftSideID, currentlyShowingSlideID);
        slideSlider(rightString);
    };
};


function ifIsBuiltIsTrue_Dissassemble() {
    // for toThePreviousPage(), toTheNextPage(), goToArbitrarySection(), & goToArbitraryPage()
    if (isBuilt && directionSliderMoving === "neither") {
        disassemble();
        isBuilt = false;
    };
};

//*******************************************************************
// Business logic

// Grab page counts embedded in HTML
var pageCountsElems = document.getElementById("pageCounts").children;
for (var i = 0; i < pageCountsElems.length; i++) {
    pageCounts[i] = parseInt(pageCountsElems[i].innerHTML);
}

// Show 0-0 card and set controls for initial use
document.getElementById("0-0").style.display = MsGrid;
onSectionChange();
setActivePageIndicator();

// Rotate through sections every 5 seconds until user breaks interaction
// Subsequently show flippers whenever the mouse moves
/*
var timer;
document.body.addEventListener("mousemove", function () {
    clearTimeout(timer);
    var flippers = document.getElementsByClassName("sideNav")
    flippers[0].style.display = MsGrid;
    flippers[1].style.display = MsGrid;

    function hideFlippers() {
        flippers[0].style.display = None;
        flippers[1].style.display = None;
    }
    timer = setInterval(hideFlippers, 300);
});
*/

// Left + right arrow key functionality
document.onkeydown = function (evt) {
    evt = evt || window.event;
    switch (evt.keyCode) {
        case 37:
            var oldPage = currentID();
            toThePreviousPage();
            RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
            WinGS.logBI("KeyPress", "{'direction':'left','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
            break;
        case 39:
            var oldPage = currentID();
            toTheNextPage();
            RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
            WinGS.logBI("KeyPress", "{'direction':'right','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
            break;
    }
};

//*******************************************************************
// Wrappers for HTML events

function pageNext() {
    var oldPage = currentID();
    toTheNextPage();
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'rightNav','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

function pagePrev() {
    var oldPage = currentID();
    toThePreviousPage();
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'leftNav','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

function sectionNext() {
    newSlideToNextSectionRight();
}

function externalNavigatePage(section, page)
{

}

function navigateToPage(page) {
    var oldPage = currentID();
    goToArbitraryPage(page);
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'pageIndicator','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

function navigateToSection(section) {
    var oldPage = currentID();
    goToArbitrarySection(section);
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'hubButton','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

// Mobile instant show/hide versions, used for better perf
function showPageNext() {
    var oldPage = currentID();
    updatePage(1);
    document.getElementById(oldPage).style.display = None;
    var target = document.getElementById(currentID());
    target.style.display = MsGrid;
    if (target.classList.contains("contentCard-specs")) {
        document.getElementsByClassName("template-pageIndicator")[0].classList.add("indicators-bottom");
    } else {
        document.getElementsByClassName("template-pageIndicator")[0].classList.remove("indicators-bottom");
    }
    pauseOrPlayVideos();
    pauseOrPlayGIFs();
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'rightNav','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

function showPagePrev() {
    var oldPage = currentID();
    updatePage(-1);
    document.getElementById(oldPage).style.display = None;
    var target = document.getElementById(currentID());
    target.style.display = MsGrid;
    if (target.classList.contains("contentCard-specs")) {
        document.getElementsByClassName("template-pageIndicator")[0].classList.add("indicators-bottom");
    } else {
        document.getElementsByClassName("template-pageIndicator")[0].classList.remove("indicators-bottom");
    }
    pauseOrPlayVideos();
    pauseOrPlayGIFs();
    RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
    WinGS.logBI("Click", "{'target':'leftNav','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
}

function showArbitrarySection(section) {
    if (section !== currentSection) {
        var oldPage = currentID();
        currentSection = section;
        currentPage = 0;
        onSectionChange();
        setActivePageIndicator();
        document.getElementById(oldPage).style.display = None;
        var target = document.getElementById(currentID());
        target.style.display = MsGrid;
        if (target.classList.contains("contentCard-specs")) {
            document.getElementsByClassName("template-pageIndicator")[0].classList.add("indicators-bottom");
        } else {
            document.getElementsByClassName("template-pageIndicator")[0].classList.remove("indicators-bottom");
        }

        pauseOrPlayVideos();
        pauseOrPlayGIFs();
        RDX.navigateEvent(document.getElementById(currentID()).getAttribute("sectionIdentifier"), document.getElementById(currentID()).getAttribute("pageIdentifier"));
        WinGS.logBI("Click", "{'target':'hubButton','oldPage':'" + oldPage + "','newPage':'" + currentID() + "'}");
    }
}

//*******************************************************************
// Miscellaneous functions

function showModal(event) {
    event.preventDefault();
    event.currentTarget.parentNode.parentNode.parentNode.firstElementChild.style.display = "";
}

function hideModal(event) {
    event.currentTarget.parentNode.parentNode.style.display = None;
}
