% MST最小生成树
% 程序利用点的集合来判断闭合条件
% 作者：李涛
% 西南交通大学PS-InSAR工作小组
clc;
clear;
% ——————参数初始化——————
num=100; % 随机点数目
plist=[]; % 样本点坐标
arcs=[]; % 弧段列表，具体格式为[[参考点X，Y]，[样本点X，Y]]
w=[]; % 权重向量，以距离为权重
w_coor=[];% 每个权重对应的点对坐标
% ——————参数初始化——————
% ——————生成并显示随机点数据————————
b=unidrnd(40000,1,num);% 构建随机数，最大值40000，维数1*10
% b=[24839,22949,2084,37249,29147,29514,2537,34418,37377,39376];
if num<2
    disp('随机点数目必须>=2');
    return;
end
for i=1:num
    plist_line=floor(b(i)/200);
    plist_column=mod(b(i),200);
    plist=[plist;plist_line,plist_column];
end
% plot(plist(:,1),plist(:,2),'or'); % 显示
% ——————生成并显示随机点数据————————
% ——————获取点对坐标以及距离信息——————
for i=1:num-1
    for j=i+1:num
        temp=((plist(i,1)-plist(j,1))^2+(plist(i,2)-plist(j,2))^2)^0.5;             
        w=[w;temp];
        w_coor=[w_coor;i,j];
    end
end
% ——————获取点对坐标以及距离信息——————        
% ——————开始进行最小生成树迭代——————
p_used=struct('p_coor',[]);% 结构体变量，用于存储用过的点集
[w,coor]=sort(w);
all_num=num*(num-1)/2;


for j=1:all_num
    p_used_size=size(p_used);
    p_coor=w_coor(coor(j),:); % 获取第j条弧段对应的点对    
    for i=1:p_used_size
        all_not_in_set=true;
        ii=find(p_used(i).p_coor==p_coor(1));
        ii=size(ii);
        jj=find(p_used(i).p_coor==p_coor(2));
        jj=size(jj);
        if ii(2)==1  % 在第i个点集中找到了弧段起点
            all_not_in_set=false;
            if jj(2)==0 % 在第i个点集中未找到弧段终点
                if i==p_used_size % i是最后的点集
                    p_used(i).p_coor=[p_used(i).p_coor,p_coor(2)];
                else % i不是最后的点集
                    for k=1:p_used_size % 这儿太让人纠结了，大神啊！
                        not_in_set=true;
                        jj=find(p_used(k).p_coor==p_coor(2));
                        jj=size(jj);
                        if jj(2)==1 % 在第k个点集中找到了弧段终点
                            not_in_set=false;
                            if k~=i                                
                                % 将两个点集合并至第i个点集中并删除第k个点集。
                                p_used(i).p_coor=[p_used(i).p_coor,p_used(k).p_coor];
                                p_used(i).p_coor=unique(p_used(i).p_coor);
                                p_used(k).p_coor=[];
                                arcs=[arcs;p_coor];
%                                 if k<p_used_size % 如果k不是最后的点集
%                                     k=k-1;
%                                     p_used_size=p_used_size-1;
%                                 end
                                break; % k循环完毕
                            end 
                        end                        
                    end
                    if not_in_set % 之后的点集中未找到弧段终点
                        p_used(i).p_coor=[p_used(i).p_coor,p_coor(2)];
                        arcs=[arcs;p_coor];
                    end
                end
            end
            all_not_in_set=false;
            break; % i循环完毕
        end        
    end
    if all_not_in_set % 所有的点集中未找到弧段起点
        not_in_set=true;
        for m=1:p_used_size % 以弧段终点为搜索条件搜索 
            jj=find(p_used(m).p_coor==p_coor(2));
            jj=size(jj);
            if jj(2)==1 % 终点在第m个点集中被发现
                p_used(m).p_coor=[p_used(m).p_coor,p_coor(1)];
                arcs=[arcs;p_coor];
                not_in_set=false;
                break; % m循环完毕
            end
        end
        if not_in_set % 终点也没有出现在任何点集中
            % 未找到起始、终止点，生成新的点集
            temp=struct('p_coor',p_coor);
            p_used=[p_used;temp];
            arcs=[arcs;p_coor];
        end
    end
    arcs_size=size(arcs);
    if arcs_size(2)==num-1
        break;
    end
% arcs'
% disp('————————循环结束————————');
end
% ——————画图——————
% start_p=plist(arcs(:,1),:);
% end_p=plist(arcs(:,2),:);
% plot([start_p(:,1),end_p(:,1)],[start_p(:,2),end_p(:,2)]);
arcs_size=size(arcs);
figure;
axis([0,200,0,200]);
for i=1:arcs_size(1);
    start_p=plist(arcs(i,1),:);
    end_p=plist(arcs(i,2),:);
    plot([start_p(1),end_p(1)],[start_p(2),end_p(2)],'g');
    hold on;

end