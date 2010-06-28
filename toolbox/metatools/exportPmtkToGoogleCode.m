function exportPmtkToGoogleCode()


username    = getConfigValue('PMTKgoogleUsername');
passwd      = getConfigValue('PMTKgooglePassword');
summary     = date();
package     = 'pmtk3';
exclusions  = {'docs', 'external', 'data'};
createEmpty = {'external', 'data'};
exportToGoogleCode(package, username, passwd, summary, exclusions, createEmpty);

end