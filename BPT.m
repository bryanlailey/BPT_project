%Importing the necessary fits files
gal_class = fitsread('gal_iclass_dr7_v5_2.fits');

spec_data = fitsread('gal_line_dr7_v5_2.fit','bintable');
spec_info = fitsinfo('gal_line_dr7_v5_2.fit');

gal_params_data = fitsread('gal_info_dr7_v5_2.fit','bintable');
gal_params_info = fitsinfo('gal_info_dr7_v5_2.fit');

%Set and apply cutoffs that z < 0.1 and S/N > 20
z_cutoff = 0.1;
z_index = gal_params_data{1,13} <= z_cutoff;

sn_cutoff = 20;
sn_index = gal_params_data{1,18} >= sn_cutoff;

cutoff_index = z_index + sn_index;
cutoff_index = cutoff_index == 2;

%Create and populate a table of dispersions, line fluxes, and classes
gal_storage = zeros(sum(cutoff_index),6);
gal_storage(:,1) = spec_data{1,3}(cutoff_index);
gal_storage(:,2) = spec_data{1,115}(cutoff_index);
gal_storage(:,3) = spec_data{1,175}(cutoff_index);
gal_storage(:,4) = spec_data{1,163}(cutoff_index);
gal_storage(:,5) = spec_data{1,91}(cutoff_index);
gal_storage(:,6) = gal_class(cutoff_index);

%Remove galaxies of the unclassifiable class
unclass_index = gal_storage(:,6) == -1;
gal_table = gal_storage(unclass_index == 0,:); 

%find and remove the 333 galaxies with key spectral lines in absorption
nrows = sum(gal_table<0,2);     
gal_table = gal_table(nrows==0,:);

%find and remove the 2 galaxies without H-balmer emission lines
nrows_zero = sum(gal_table==0,2);       
gal_table = gal_table(nrows_zero==0,:);

%find and remove the low S/N star forming galaxies
nrows_lowsn_sf = sum(gal_table(:,6)==2,2);       
gal_table = gal_table(nrows_lowsn_sf==0,:);

%find and remove the low S/N AGN galaxies
nrows_lowsn_agn = sum(gal_table(:,6)==5,2);       
gal_table = gal_table(nrows_lowsn_agn==0,:);

%calculate the log of the line ratios
y = log10(gal_table(:,2) ./ gal_table(:,5));        
x = log10(gal_table(:,3) ./ gal_table(:,4));

%create a vector of marker sizes from the sigma velocity dispersions 
sz = zeros(1,length(gal_table));               
for i = 1:length(gal_table)
    if gal_table(i,1) <= 100
        sz(i) = 2;
    elseif gal_table(i,1) > 100 && gal_table(i,1) <= 200
        sz(i) = 5;
    elseif gal_table(i,1) > 200 && gal_table(i,1) <= 300
        sz(i) = 9;    
    else sz(i) = 14;
    end
end

%convert IBM Design Library colour blind RGB scheme into the range [0 1]
bl = [100 143 255]./255;        
pnk = [220 38 127]./255;
orng = [255 176 0]./255;

%assign a colour to each galaxy based on Brinchmann et al (2004)
marker_colour = zeros(length(gal_table),3);       
for j = 1:length(gal_table)
    if gal_table(j,6) == 1 
        marker_colour(j,:) = bl;   
    elseif gal_table(j,6) == 3  
        marker_colour(j,:) = pnk;
    else marker_colour(j,:) = orng;    
    end
end

%create Kewley, Kauffmann, and Schawinski lines
xk = linspace(-2,0.3,200);
yk = (0.61./(xk - 0.47)) + 1.19;
xs = linspace(-0.18,0.6,100);
ys = 1.05.*xs + 0.45;
xa = linspace(-2,0,200);
ya = 0.61./(xa - 0.05) + 1.3;

%create BPT plot
fig = figure();
ax = axes(fig);
hold(ax,'on')
BPT_plot = scatter(x,y,sz,marker_colour,'filled');
BPT_plot.MarkerFaceAlpha = 0.8;
set(gcf,'color','w');
xlim([-2 1])
ylim([-1.5 1.5])
xlabel('log([NII] \lambda = 6583 / H\alpha)')
ylabel('log([OIII] \lambda = 5007 / H\beta)')


%add Kewley, Kauffmann, and Schawinski lines to plot
plot(xk,yk,'-k');
hold on;
text(xk(195),yk(195)+0.15,'Ke01')
hold on;
plot(xs,ys,'-.k');
hold on;
plot(xa,ya,'--k');
hold on;
text(xa(183),ya(183)+0.13,'Ka03')
hold on;
text(xs(90),ys(90)-0.06,'Sc07')
hold on;

%create custom legends
h(1) = scatter(NaN,NaN,4,bl,'filled');
h(2) = scatter(NaN,NaN,4,pnk,'filled');
h(3) = scatter(NaN,NaN,4,orng,'filled');

g(1) = scatter(NaN,NaN,4,'ok','filled');
g(2) = scatter(NaN,NaN,4,'ok','filled');
g(3) = scatter(NaN,NaN,4,'ok','filled');
g(4) = scatter(NaN,NaN,4,'ok','filled');

leg1 = legend(h, 'Star Forming', 'Composite', 'AGN','Position',[0.16 0.35 0.19 0.15]); 
leg2 = legend(g, '    0 < \sigma < 50 kms^-^1', '  50 < \sigma < 100 kms^-^1', '100 < \sigma < 200 kms^-^1',...
'300 < \sigma < 500 kms^-^1','Location','west');
objhl = findobj(objh, 'type', 'patch'); 
set(objhl, 'Markersize', [2 5 9 14]); 