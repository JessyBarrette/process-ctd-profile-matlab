function plotRawVsProcess(rawRSK, finRSK,x_vars, preBinRSK)




[hlr,axlr] = RSKplotprofiles(rawRSK,'channel',x_vars);
[hlf,axlf] = RSKplotprofiles(finRSK,'channel',x_vars);

% Put Raw lines in red
for ii=1:length(hlr(:))
    hlr(ii).Color='r';
end
linkaxes([axlr,axlf],'y')
for jj = 1:length(axlf(:))
    legend(axlf(jj),[hlr(1:2),hlf(1:2)],{'raw: Downcast','raw: Upcast','process: Downcast','process: Upcast'})
end
end