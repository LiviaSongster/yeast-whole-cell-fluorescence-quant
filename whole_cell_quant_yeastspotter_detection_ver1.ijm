// TO RUN: select folder containing all your BLINDED movies as .nd2 files.
// make sure they are all in the same format (i.e., green channel first, then DIC)

// GOALS:
// 1) analyze the fraction of fluorescence signal coming from very bright puncta vs. all signal within the cell
// 2) expect high percentage = less diffuse fluorescence

mainDir = getDirectory("Choose a directory containing your files:"); 
maxDir = mainDir+"Output-MaxZ"+File.separator;
sumDir = mainDir+"Output-SumZ"+File.separator;
yeastDir = mainDir+"yeastspotter"+File.separator;
// finds all the filenames within the folder you select
maxList = getFileList(maxDir); 
sumList = getFileList(sumDir); 
yeastList = getFileList(yeastDir);

// make a new folder to hold all the outputs at the very end
finalDir = mainDir+"Whole-Cell-Quant-MaxZ-Results"+File.separator;
File.makeDirectory(finalDir);
finalDir2 = mainDir+"Whole-Cell-Quant-SumZ-Results"+File.separator;
File.makeDirectory(finalDir2);

// default assumes files are all .tif - will NOT analyze if filetype is not tif
// can change this variable to .tif or anything else if you need to
imageType = ".tif";

// clunky, loops thru all items in folder looking for image
for (m=0; m<maxList.length; m++) { // m is iterator
	 
	 // if filename list is tif, execute following code. otherwise, skip the file
	if (endsWith(maxList[m], imageType)) {

		// set measurements you want
		run("Set Measurements...", "area mean centroid shape integrated redirect=None decimal=3");
		
		open(maxDir+maxList[m]); //open image file on the maxZ list
		title = getTitle(); //save the title of the movie
		name = substring(title, 0, lengthOf(title)-4);
		run("Split Channels");
		close("C1-"+title);
			
		open(sumDir+sumList[m]); //open image file on the sumZ list
		sumtitle = getTitle(); //save the title of the movie
		sumname = substring(sumtitle, 0, lengthOf(sumtitle)-4);
		run("Split Channels");
		close("C1-"+sumtitle);
		// open the yeastspotter image
		open(yeastDir+name+"_yeastspotter.tif");
		run("Analyze Particles...", "exclude clear add");
		
		// analyze particles to detect cells and then analyze max image
		array1 = newArray("0"); 
		for (array1i=1;array1i<roiManager("count");array1i++){ 
    			array1 = Array.concat(array1,array1i); 
     		} //array1i is an iterator ('i')

        // analyze maxZ first
		selectWindow("C2-"+title);
		roiManager("select", array1);
		roiManager("Measure"); //measure   	 
		saveAs("Results", finalDir+name+"_WholeCellQuant_Results.csv"); //save
		selectWindow("Results");  
		run("Close"); //close
		
		// next sumZ image
		selectWindow("C2-"+sumtitle);
		roiManager("select", array1);
				roiManager("Measure"); //measure   	 
		saveAs("Results", finalDir2+sumname+"_WholeCellQuant_Results.csv"); //save
		selectWindow("Results");  
		run("Close"); //close

		roiManager("save selected", yeastDir+name+"_CellRoiSet.zip");       		
		selectWindow("ROI Manager");
		run("Close"); //close
		close("*");
		
	} // end if loop
} // end initial forloop

