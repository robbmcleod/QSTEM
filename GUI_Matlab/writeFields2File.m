function writeFields2File(fileName,handles)

fid = fopen(fileName,'w');
if fid == -1
    msgbox(sprintf('Could not open file %s!',fileName));
    return
end


fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf(fid,'%% STEM configuration file generated by qstem\n');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n');

switch handles.modeNum
    case 2
        fprintf(fid,'mode: CBED\n');
    case 1
        fprintf(fid,'mode: STEM\n');
    case 0
        fprintf(fid,'mode: TEM\n');        
end
fprintf(fid,'print level: %d  %% indicates how much information in output\n',handles.printLevel);
fprintf(fid,'save level:  %d  %% indicates how much information shall be saved \n',handles.saveLevel);
% Now we need to know whether the .cfg file is saved in the same directory as
% the config file:
[posPath,posName] = fileparts(handles.posFileName);
[cfgPath,cfgName] = fileparts(fullfile(handles.configPath,handles.configFile));
% strcmp(posPath,cfgPath)
if strcmp(posPath,cfgPath) == 1
    firstChar = findstr(handles.posFileName,'\');
    if isempty(firstChar)
        fprintf(fid,'filename: %s \n',handles.posFileName);
    else
        fprintf(fid,'filename: %s \n',handles.posFileName(firstChar(end)+1:end));
    end
else
    fprintf(fid,'filename: "%s" \n',handles.posFileName);
end
fprintf(fid,'resolutionX:  %f \n',handles.ProbeResolutionX);
fprintf(fid,'resolutionY:  %f \n',handles.ProbeResolutionY);

fprintf(fid,'NCELLX: %d\n',handles.NcellX);
fprintf(fid,'NCELLY: %d\n',handles.NcellY);
if handles.NsubSlabs <= 1
    fprintf(fid,'NCELLZ: %d\n',handles.NcellZ);
else
     fprintf(fid,'NCELLZ: %d/%d\n',handles.NcellZ,handles.NsubSlabs);   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box confinement:
if isfield(handles,'radiobutton_Box')
    if get(handles.radiobutton_Box,'Value')
        fprintf(fid,'Cube: %.3f %.3f %.3f\n',handles.BoxX,handles.BoxY,handles.BoxZ);
    end
else
    if handles.BoxMode
        fprintf(fid,'Cube: %.3f %.3f %.3f\n',handles.BoxX,handles.BoxY,handles.BoxZ);
    end
end

fprintf(fid,'v0: %f  %% beam energy\n',handles.HighVoltage);
if isfield(handles,'checkbox_TDS')
    handles.TDS         = get(handles.checkbox_TDS,'Value');
end
% fprintf('TDS is set to %d\n',handles.TDS);
if handles.TDS == 1
    fprintf(fid,'tds: yes %% include thermal diffuse scattering\n');
else
    fprintf(fid,'tds: no %% do NOT include thermal diffuse scattering\n');
end        
fprintf(fid,'temperature: %f	%% temperature in Kelvin \n',handles.Temperature);
fprintf(fid,'slice-thickness: %f  %% slice thckness in A\n',handles.SliceThickness);
fprintf(fid,'slices: %d		%% number of different slices per slab in z-direction\n',handles.Nslice);
if handles.CenterSlices
    fprintf(fid,'center slices: yes      %% center slices\n');
else
    fprintf(fid,'center slices: no       %% do not center slices\n');    
end
fprintf(fid,'slices between outputs: %d  %% give intermediate results after every %d slices\n',...
    handles.SlicesBetweenOutputs,handles.SlicesBetweenOutputs);

fprintf(fid,'xOffset:  %f   %%  x-position offset in cartesian coords \n',handles.PotentialOffsetX);
fprintf(fid,'yOffset:  %f   %%  y-position offset in cartesian coords \n',handles.PotentialOffsetY);
fprintf(fid,'zOffset:  %f   %%  slize z-position offset in cartesian coords \n',handles.PotentialOffsetZ);
if handles.PeriodicXY
    fprintf(fid,'periodicXY: yes	%% periodic in x- and y-direction\n');
else
    fprintf(fid,'periodicXY: no		%% not periodic in x- and y-direction\n');
end
if handles.PeriodicZ
    fprintf(fid,'periodicZ: yes		%% periodic in z-direction\n');
else
    fprintf(fid,'periodicZ: no		%% not periodic in z-direction\n');
end

if (handles.modeNum == 1) || (handles.modeNum == 2)
    fprintf(fid,'\n%% Scanning window \n');
    fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n\n');
    fprintf(fid,'scan_x_start:  %f  %% X position of top left corner of scan window \n',handles.Xstart);
    fprintf(fid,'scan_x_stop:   %f	%% X position of bottom right corner of scan window \n',handles.Xstop);
    fprintf(fid,'scan_x_pixels: %d	%% number of pixels in X-direction \n',handles.Xpixels);
    fprintf(fid,'scan_y_start:  %f \n',handles.Ystart);
    fprintf(fid,'scan_y_stop:   %f \n',handles.Ystop);
    fprintf(fid,'scan_y_pixels: %d \n',handles.Ypixels);
end

if handles.modeNum == 1
    fprintf(fid,'\n%% STEM detectors \n');
    fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n');
    fprintf(fid,'%% syntax: rInside rOutside name (name will be used to store images under) \n\n');
    
    for jd = 1:size(handles.Detectors,1)
        fprintf(fid,'detector: %f %f detector%d %f %f\n',handles.Detectors(jd,1),handles.Detectors(jd,2),jd,...
            handles.Detectors(jd,3),handles.Detectors(jd,4));
    end
end


fprintf(fid,'\n%% Geometrical properties \n');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n\n');
fprintf(fid,'Crystal tilt X: %f	%% tilt in rad \n',handles.TiltX);
fprintf(fid,'Crystal tilt Y: %f  \n',handles.TiltY);
fprintf(fid,'Crystal tilt Z: %f  \n',handles.TiltZ);
fprintf(fid,'Beam tilt X: %f deg	%% beam tilt deg \n',handles.BeamTiltX);
fprintf(fid,'Beam tilt Y: %f deg \n',handles.BeamTiltY);
if (handles.TiltBack)
    fprintf(fid,'Tilt back: yes \n');
else
    fprintf(fid,'Tilt back: no \n');    
end
% model confined in box:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ax=160.146A, by=53.8081A, cz=189.059A

switch handles.modeNum
    case 2
        fprintf(fid,'\n%% CBED probe parameters \n');
    case 1
        fprintf(fid,'\n%% STEM probe parameters \n');
    case 0
        fprintf(fid,'\n%% TEM imaging parameters \n');        
end
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n\n');
fprintf(fid,'nx: %d		%% array size used for probe \n',handles.ProbeNx);
fprintf(fid,'ny: %d     %% ny = nx, if not specified\n',handles.ProbeNy);
fprintf(fid,'Cs: %f		%% Spherical abberation in mm\n',handles.C3);
fprintf(fid,'C5: %f		%% C_5 abberation in mm\n',handles.C5);  
fprintf(fid,'Cc: %f	    %% Chromatic abberation in mm\n',handles.Cc);
fprintf(fid,'dV/V: %f	%% energy spread in eV (FWHM)\n',1e-3*handles.dE/handles.HighVoltage);
fprintf(fid,'alpha: %f	 %% Illumination angle in mrad\n',handles.alpha);
fprintf(fid,'defocus: %f	\n',handles.Defocus);	
fprintf(fid,'astigmatism: %f	\n',handles.AstigMag);	
fprintf(fid,'astigmatism angle: %f	\n',handles.AstigAngle);	
% Write all the other aberrations as well:
for ix=3:6
    for iy=1:6
        if abs(handles.a(ix,iy)) > 0
            fprintf(fid,'a_%d%d: %f	\n',ix,iy,handles.a(ix,iy));
            fprintf(fid,'phi_%d%d: %f	\n',ix,iy,180/pi*handles.phi(ix,iy));            
        end
    end
end
fprintf(fid,'\n\n');
fprintf(fid,'Source Size (diameter): 0  %% source size in A\n');
fprintf(fid,'beam current: 1         %% beam current in pA (default: 1)\n');
fprintf(fid,'dwell time: 1.6021773e-4 %% dwell time in msec (default: 1)\n');
fprintf(fid,'smooth: yes		%% smoothen edge of probe in rec. space\n');
fprintf(fid,'gaussian: no		% Apply gaussian smoothing on CBED probe\n');

fprintf(fid,'\n%% Parameters for potential calculation\n');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n\n');
fprintf(fid,'potential3D:          yes  %% use 3D or 2D potential (3D realistically simulates z-motion of atoms)\n');
fprintf(fid,'atom radius:          %.1f	%% radius used for calculation of proj potential V_proj(r)\n',handles.atomRadius);
fprintf(fid,'plot V(r)*r:          no	%% will create a plot for V_proj(r)*r vs. r  for all slices and 1st atom\n');
fprintf(fid,'bandlimit f_trans:    no	%% indicate whether to band limit transmission function or not\n');
if handles.savePotential
    fprintf(fid,'save potential:       yes	%% whether we want to save the projected potential in files\n');
else
    fprintf(fid,'save potential:       no	%% whether we want to save the projected potential in files\n');
end
if handles.saveTotalPotential
    fprintf(fid,'save projected potential:       yes	%% whether we want to save the total projected potential\n');
else
    fprintf(fid,'save projected potential:       no	%% whether we want to save the total projected potential\n');
end

fprintf(fid,'one time integration: yes  %% calculate V_proj once and then copy (much faster) \n');

fprintf(fid,'Display Gamma: 0     %% Gamma value for image scaling (0 = logarithmic)\n');
fprintf(fid,'Folder: "%s"\n',handles.OutputFolder);
fprintf(fid,'Runs for averaging: %d  %% averaging over %d images for TDS simulation\n',...
    handles.TDSruns,handles.TDSruns);
% choose beteen Doyle-Turner (DT=default) and Weickenmeier-Kohl (WK) 
fprintf(fid,'Structure Factors: WK\n');
fprintf(fid,'show Probe: no		%% displays a graph of the crosssection of the inc. e-beam\n');
fprintf(fid,'propagation progress interval: %d %% show progress every N_prop_prog beam positions\n',handles.propProgInterval);
fprintf(fid,'potential progress interval: %d %% show progress every N_pot_prog atoms\n',handles.potProgInterval);
fprintf(fid,'update Web: no		%% put results on web page\n');

% Multislice procedure:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'Pendelloesung plot: no  %% flag indicates whether to store Pendeloesung plot\n');
fprintf(fid,'sequence: 1 1\n');

fclose(fid);



