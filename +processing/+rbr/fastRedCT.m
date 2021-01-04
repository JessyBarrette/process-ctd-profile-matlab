% RBR Newer generation of CTDs are equipped of a red conductivity cell
% combined with a temperature sensor mounted next to it. This spatial
% location  reduce greatly the lag needed to appropriately correct the 
% misalignment of the temperature and condutivity sensors.

process.smoothCT.windowLength = 3;

process.alignCT.lag = 0.05;
process.alignCT.lagunits = 'seconds';

process.alignDO.lag = -3; % This is generally true for fast Rinko sensors equipped on RBR older units
process.alignDO.lagunits = 'seconds';