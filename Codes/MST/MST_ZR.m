%最小生成树构网
%随机生成数据
clc;
clear;
a=zeros(200,200);
b=unidrnd(40000,1,10);
a(b)=1;
%定义参考变量
plist=[]; %样本点坐标
Num=0; %弧段数目
arcs=[]; %弧段列表，具体格式为[[参考点X，Y]，[样本点X，Y]]
%获取点位信息
for i=1:200
    for j=1:200
        if a(i,j)==1 
            plist=[plist;i,j];
        end
    end
end
plot(plist(:,1),plist(:,2),'or');
hold on
[lines,r2]=size(plist);
Num=lines-1;
%生成邻接矩阵
w=ones(lines,lines)*inf;
for i=1:Num
    for j=i+1:lines
        dd=((plist(i,1)-plist(j,1))^2+(plist(i,2)-plist(j,2))^2)^0.5;
        w(i,j)=dd;
%         w(j,i)=dd;
    end
end
% [arc,w2]=mst_cal(w);
% % arc=E;
% %构建弧度信息
% startp=plist(arc(:,1),:);
% endp=plist(arc(:,2),:);
% arcs=[startp,endp];
% for k=1:Num
%     plot([arcs(k,1),arcs(k,3)],[arcs(k,2),arcs(k,4)],'.-b');
%     hold on
% end
% hold off
d=100000;x=1;y=0;
n=lines;
for j=2:n
    if w(1,j)<d
        d=w(1,j);
        y=j;
    end
end
ssdd=[1,j];
E=[1,j];
arc=[plist(1,1),plist(1,2),plist(y,1),plist(y,2)];
plot([arc(1,1),arc(1,3)],[arc(1,2),arc(1,4)]);
hold on
jgkdfls;
% %迭代搜索
% seed=[];
% w(x,y)=inf; %迭代得到的边注释掉   
% for i=1:n-2
% %     yt=find(w(x,:)==min(w(x,:)));
%     d=inf;yt=0;
%     for j=1:n
%         if w(x,j)<d
%             yt=j;d=w(x,j);
%         end
%     end
%     if yt~=0
%         seed=[seed;x,yt];
%     end
% %     xt=find(w(:,y)==min(w(:,y)));
%     d=inf;xt=0;
%     for j=1:n
%         if w(j,y)<d
%             xt=j;d=w(j,y);
%         end
%     end
%     if xt~=0
%         seed=[seed;xt,y];
%     end
%     [num_seed,ttt]=size(seed);
% %     array=w(seed(:,1),seed(:,2));
% %     array=zeros(2*n);
%     d=inf;id=0;
% %     id=find(array==min(array));
%     for j=1:num_seed
%         array=w(seed(j,1),seed(j,2));
%         if array<d
%             id=j;d=array;
%         end
%     end
% %     if id==0
% %         disp('error');
% %         pause
% %     end
%     x=seed(id,1);y=seed(id,2);
%     %新进点判断
%     t1=find(ssdd==x);
%     [tx,ty]=size(t1);
%     if ty==0
%         for k=1:i+1
%             w(x,ssdd(k))=inf;
%             w(ssdd(k),x)=inf;
%         end
%         ssdd=[ssdd,x];
%     else
%         for k=1:i+1
%             w(y,ssdd(k))=inf;
%             w(ssdd(k),y)=inf;
%         end
%         ssdd=[ssdd,y];
%     end
%     E=[E;x,y];
%     
% end
