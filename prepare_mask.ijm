//Open image sequence containing grayscale images of scan of interest
run("Open...");
rename("scan");

ns = nSlices;
setSlice(ns/3);

//User needs to adjust birgthness and contrast manually before continuing
run("Brightness/Contrast...");
waitForUser("Adjust brightness and contrast, then click OK");

//Open Amira/Avizo segmentation file (.am), 
//with all segements or specific segments
run("Amira...");
rename("segments");

//Apply different LUT to the segmentation stack, 
//to highlight the different segments with different gray values
run("Grays")

//Find maximum (i.e. clearest) gray value, and set min and max values 
//for the stack based on 0 (black) and maximum + 1 (white), 
//this allows for the different segements to be clearly differentiated
//in terms of gray value visible on the stack
selectImage("segments");
run("Statistics");
max = getResult("Max", 0);
max = max + 1;
min = 0;
//print(min+"-"+max);
setMinAndMax(min, max);
run("Apply LUT", "stack");
close("Results");

ns = nSlices;
setSlice(ns/3);

//Create an array to fill with cumulative number of pixels for each
//gray value (gray scale goes from 0 to 255)
stackHisto = newArray(256);
for ( j=1; j<=nSlices; j++ ) {
    setSlice( j );
    getHistogram( values, counts, 256 );
    for ( i=0; i<256; i++ ) {
       stackHisto[i] += counts[i];
    }
}
//Plot.create( "Stack-Histogram", "Count", "Gray-value", stackHisto );
Array.show("Results", stackHisto);

//Go through results of created array, searching for gray values 
//which have more than 0 pixels. When one such value is found
//(i.e. corresponding to one segment), the threshold is set to
//this value, and a binary mask is created, which will allow 
//to mask the original scan with each individual segment.
for (i=1; i<256; i++) {
	row = i;
	a = getResult("Value", row);
	//print(a);

	if (a>0) {
		//print(a);
		thr = i;
		setThreshold(thr, thr);
		waitForUser("Check which muscle is masked");
		selectImage("segments");
		run("Make Binary", "background=Dark black create");
		rename("MASK");
		imageCalculator("AND create stack", "MASK","scan");
		run("Image Sequence... ");
		selectImage("Result of MASK");
		close();
		selectImage("MASK");
		close();
		}
selectImage("segments");	
//resetThreshold;
}
