Title: README file for the Goodfibes pipeline
Author: Samuel Ginot
Date created (DD/MM/YYYY): 23/04/2024
GitHub repository (at the moment private) URL: https://github.com/sginot/pipeline_disparat

This file aims to explain step by step how to run the Fiji/ImageJ and R pipeline to model muscle fibers using R package GoodFibes, starting from an image stack of a CT scanned, iodine stained and 3D reconstructed specimen.

The repository contains three scripts, two containing ImageJ Macros and one an R script:
- prepare_mask.ijm takes as input 1) a reconstructed image stack (any format supported by ImageJ should work) and 2) an image stack of a segmentation of all structures of interest (.am format, i.e. segmentation from Amira/Avizo). It outputs stacks of the same dimensions, each stack containing a single structure (e.g. one muscle) in grayscale, with the rest of the image masked as black pixels. Outputs are saved as stacks of 16-bits .png images into user-defined folder(s). The format of the output corresponds to the requirements of the GoodFibes R package.
- slices_reorient takes as input the (user-defined) slice orientation of an opened stack, and reslices it to obtain different orientation(s). The reoriented stacks can then be saved by users.
- goodfibes_script.R takes as input a folder containing masked stacks of various structures (filenames format: structureABC_XXXX.png with XXXX being number padding of slices), and runs various loops to produce fiber models, compute fiber lengths and angles, and export as STLs.

All of the scripts require user interaction, to adjust the brightness/contrast of the original reconstructed image stack, to open and save specific locations, to define orientation/reorientation, voxel size and so on... This limits automatization but is required because not all scans have the same resolution, not all structures have the same gray values (adequate thresholds will vary from scan to scan and muscle to muscle).
