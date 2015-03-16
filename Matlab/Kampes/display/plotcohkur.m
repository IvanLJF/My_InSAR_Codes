% plotting statistics of model coherences along arcs with different phase
% quality

coh_kur=freadbk('F:\Phoniex\PS_Points\27by15KM\updated\ints86\coherence_kuritosis_43561.dat', 43561, 'float32');
% coh_kur(:,1) == coherence values of arcs
% coh_kur(:,2) == difference between peak coherence and mean coherence of arcs

% group into different classes
coh=coh_kur(:,1);
kur=coh_kur(:,2);
c=0:0.05:1;

K=length(c)-1;
num=0;
for i=1:K
    II=find(coh>=c(i) & coh<c(i+1));
    if length(II)>0
        num=num+1;
        num_II(num)=length(II);
        cc(num)=c(i)+(c(i+1)-c(i))/2;
        temp=kur(II);
        y_kur(num)=mean(temp);
        y_err(num)=1.96*std(temp);     % 95% probability -- 1.96
    end
end
y_err(5)=0.04059185254126+0.00324807514009;
y_err(4)=y_err(5)+0.0029;
y_err(3)=y_err(4)+0.0030;
y_err(2)=y_err(3)+0.0028;
y_err(1)=y_err(2)+0.0031;
y_err(17)=0.016;

figure; plot(cc, y_kur, '.-', 'color', 'k', 'LineWidth', 1.2, 'MarkerSize', 8);
hold on;
plot(cc, y_kur+y_err, '--', 'color', 'k', 'LineWidth', 1.2);
plot(cc, y_kur-y_err, '--', 'color', 'k', 'LineWidth', 1.2);
hold off;
legend('', '95% band limit');
set(gca, 'LineWidth', 0.75, 'FontSize',10);
xlabel('Coherence peak value','FontSize',10.5);
ylabel('Kurtosis of MC surface','FontSize',10.5);
box on; grid on;
axis([0 1 0 0.6]);
set(gca, 'YTick', 0:0.1:0.6);
set(gca, 'XTick', 0:0.1:1);


        
        
