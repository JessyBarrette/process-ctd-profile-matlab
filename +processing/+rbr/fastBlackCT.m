% RBR Older generation of CTDs are equipped of a black conductivity cell
% and a seperated temperature sensor which is mounted on the main housing.
% A greater lag is needed to appropriately correct the misalignment of the
% temperature and condutivity sensors.

process.smoothCT.windowLength = 3;

process.alignCT.lag = 1/3;
process.alignCT.lagunits = 'seconds';

process.alignDO.lag = -3; % This is generally true for fast Rinko sensors equipped on RBR older units
process.alignDO.lagunits = 'seconds';