import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
using Toybox.Math;
using Toybox.StringUtil;
using Toybox.System;

class PWRBasedColourView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var pSamples;
    hidden var tmp;
    hidden var labelID;
    hidden var sPWR3s;
    hidden var sPWR10s;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        pSamples = [];
        tmp = 0;
        labelID = "label";
        sPWR3s = Properties.getValue("PWR3s");
        sPWR10s = Properties.getValue("PWR10s");
    }

    // Set your layout here. 
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        var screenWidth = dc.getWidth();  // Get the screen width
        var apeVersion = System.getDeviceSettings().monkeyVersion; // Get the MonkeyC Version to determine between devices
        if ((apeVersion[0] == 3 && apeVersion[1] == 3 && apeVersion[2] == 1) && (screenWidth == 122 || screenWidth == 246)) {  // For Edge 830
            var labelView = View.findDrawableById(labelID) as Text;
            labelView.locY = labelView.locY - 22;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 12;
        } else if ((apeVersion[0] == 3 && apeVersion[1] == 3 && apeVersion[2] == 1) && (screenWidth == 140 || screenWidth == 282)) {  // For Edge 1030
            var labelView = View.findDrawableById(labelID) as Text;
            labelView.locY = labelView.locY - 25;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 17;
        } else if ((apeVersion[0] == 5 && apeVersion[1] == 0 && apeVersion[2] == 0) && (screenWidth == 239 || screenWidth == 480)) {  // For Edge 1050
            var labelView = View.findDrawableById(labelID) as Text;
            labelView.locY = labelView.locY - 33;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 18;
        } else if ((apeVersion[0] == 5 && apeVersion[1] == 0 && apeVersion[2] == 0) && (screenWidth == 140 || screenWidth == 282)) {  // For Edge 1040
            var labelView = View.findDrawableById(labelID) as Text;
            labelView.locY = labelView.locY - 20;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 12;
        } else {  // For Edge 840
            var labelView = View.findDrawableById(labelID) as Text;
            labelView.locY = labelView.locY - 15;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 12;
        }
        
        // Change label based on application setting for 3s or 10s power
        if (sPWR10s == true) {
            (View.findDrawableById(labelID) as Text).setText(Rez.Strings.PWR10slabel);
        } else if (sPWR3s == true) {
            (View.findDrawableById(labelID) as Text).setText(Rez.Strings.PWR3slabel);
        } else {
            (View.findDrawableById(labelID) as Text).setText(Rez.Strings.label);
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // Power calculation based on app setting. Either 3s or 10s.
    function compute(info as Activity.Info) as Void {
    if (info has :currentPower) {
        if(info.currentPower != null) {
            pSamples.add(info.currentPower);
            if (sPWR10s == true && pSamples.size() >= 10) { // 10s power calcualtion
            tmp = pSamples.slice(-10, null);
            mValue = (tmp[0] + tmp[1] + tmp[2] + tmp[3] + tmp[4] + tmp[5] + tmp[6] + tmp[7] + tmp[8] + tmp[9]) / 10.0 as Number;
            labelID = "PWR10slabel";
            } else if (sPWR3s == true && pSamples.size() >= 3) { // 3s power calculation 
            tmp = pSamples.slice(-3, null);
            mValue = (tmp[0] + tmp[1] + tmp[2]) / 3.0 as Number;
            labelID = "PWR3slabel";
        } else { // in case there are less then 3 samples of power values
            mValue = 0.0f;
            labelID = "label";
        }
        // Slice the array by 1 if it grows bigger then 10 values. To be save in terms of memory consumption
        var maxSize = 10; // Maximum needed size
        if (pSamples.size() > maxSize) {
            pSamples = pSamples.slice(1, null); // Slice the array to exclude the oldest element
        }
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        var hinter = View.findDrawableById("Background") as Text;
        // Get PWR zone settings from configuration
        var cPWRZone2 = Properties.getValue("PWRZone2");
        var cPWRZone3 = Properties.getValue("PWRZone3");
        var cPWRZone4 = Properties.getValue("PWRZone4");
        var cPWRZone5 = Properties.getValue("PWRZone5");
        var cPWRZone6 = Properties.getValue("PWRZone6");
        var cPWRZone7 = Properties.getValue("PWRZone7");
        // Change the background color according to power zone defined in settings
        if (mValue >= cPWRZone7 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_PURPLE);
        } else if (mValue >= cPWRZone6 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_RED);
        } else if (mValue >= cPWRZone5 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_ORANGE);
        } else if (mValue >= cPWRZone4 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_YELLOW);
        } else if (mValue >= cPWRZone3 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_GREEN);
        } else if (mValue >= cPWRZone2 && mValue != 0.0f) {
            hinter.setColor(Graphics.COLOR_BLUE);
        } else {
            hinter.setColor(getBackgroundColor());
        }

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        if (mValue >= cPWRZone2 && mValue != 0.0f) {
            value.setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById(labelID) as Text).setColor(Graphics.COLOR_WHITE);
        } else if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById(labelID) as Text).setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
            (View.findDrawableById(labelID) as Text).setColor(Graphics.COLOR_BLACK);
        }
        value.setText(mValue.format("%.0f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
