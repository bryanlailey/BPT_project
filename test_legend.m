figure
    hold on
    %sets up data for the legend
    list1 = plot(nan, nan,'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 0.5);
    list2 = plot(nan, nan,'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 1.2);
    list3 = plot(nan, nan,'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 2);
    list4 = plot(nan, nan,'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 3);
    
    
  lgd = legend([list1 list2 list3 list4], '    0 < \sigma < 50 kms^-^1',...
   '  50 < \sigma < 100 kms^-^1', '100 < \sigma < 200 kms^-^1', '300 < \sigma < 500 kms^-^1', 'AutoUpdate','Off', 'Location', 'northwest');