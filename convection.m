
%     height850 = find(goodfinal(e).pressure == 85000);
%     hpatemp850 = goodfinal(e).temp(height850);
%     hpadewpt850 = goodfinal(e).dewpt(height850);
%     height500 = find(goodfinal(e).pressure == 50000);
%     hpatemp500 = goodfinal(e).temp(height500);
%     height700 = find(goodfinal(e).pressure == 70000);
%     hpadewpt700 = goodfinal(e).dewpt(height700);
%     
%     goodfinal(e).warmnose.kindex = ((hpatemp850 - hpatemp500) + hpadewpt850 - hpadewpt700);

%     if goodfinal(e).warmnose.kindex >= 20
%        goodfinal(e).warmnose.convection = 1;
%     else
%        goodfinal(e).warmnose.convection = 0;
%     end