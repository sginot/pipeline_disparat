//An image stack must already be opened in Fiji

rename("original")

//Create variables for dialog box 
rows = 1;
columns = 3;
n = rows*columns;
labels = newArray(n);
defaults = newArray(n);
Array.fill(defaults, false);
labels[0] = "Coronal";
labels[1] = "Sagittal";
labels[2] = "Transverse";

//Array.show(defaults);
//Array.show(labels);

//Pop-up dialog box to define orientation of original stack
Dialog.create("Orientation of original slices");
Dialog.addCheckboxGroup(rows,columns,labels,defaults);
Dialog.show();

//Create array with values corresponding to the 
//orientation(s) selected.
orient = newArray(n);
for (i=0; i<n; i++) {
	val = Dialog.getCheckbox();
    //print(labels[i]+": "+val);
    orient[i] = val;
}

//Pop-up dialog box to define orientation(s) to
//which stack should be resliced.
Dialog.create("Convert to which orientation(s)?");
Dialog.addCheckboxGroup(rows,columns,labels,defaults);
Dialog.show();

//Create array with values corresponding to the 
//NEW orientation(s) selected.
neworient = newArray(n);
for (i=0; i<n; i++) {
	vall = Dialog.getCheckbox();
    //print(labels[i]+": "+vall);
    neworient[i] = vall;
}

//Reslicing from Coronal original slices
if (orient[0] == 1 && neworient[0] == 1) {
	selectImage("original");
	print("Coronal > Coronal, nothing to do!");
}
 
if (orient[0] == 1 && neworient[1] == 1) {
	selectImage("original");
	print("Coronal > Sagittal, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("sagittal");
}

if (orient[0] == 1 && neworient[2] == 1) {
	selectImage("original");
	print("Coronal > Transverse, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("transverse");
}

//Reslicing from Sagittal original slices
if (orient[1] == 1 && neworient[0] == 1) {
	selectImage("original");
	print("Sagittal > Coronal, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("coronal");
}
 
if (orient[1] == 1 && neworient[1] == 1) {
	selectImage("original");
	print("Sagittal > Sagittal, nothing to do!");
}

if (orient[1] == 1 && neworient[2] == 1) {
	selectImage("original");
	print("Sagittal > Transverse, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("transverse");
}

//Reslicing from Transverse original slices
if (orient[2] == 1 && neworient[0] == 1) {
	selectImage("original");
	print("Transverse > Coronal, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("coronal");
}
 
if (orient[2] == 1 && neworient[1] == 1) {
	selectImage("original");
	print("Transverse > Sagittal, reslicing...");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("sagittal");
}

if (orient[2] == 1 && neworient[2] == 1) {
	selectImage("original");
	print("Transverse > Transverse, nothing to do!");
}
