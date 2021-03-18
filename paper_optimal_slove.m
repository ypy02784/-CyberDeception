function [x,fval,exitflag,output] = paper_optimal_slove()
%PAPER_OPTIMAL_ 此处显示有关此函数的摘要
%x(1)-x(12) 攻击方的12个概率值，状态1，概率为x1-x3，状态2概率为4-6,以此类推
%x(13)-x(24)防守方的12个概率值
%x(25)-x(28)攻击方1-4阶段收益值
%x(29)-x(32)防守方1-4阶段收益值
%   此处显示详细说明
global AP_num DP_num State_num state_trans_p revenue_Matrix;%全局变量

AP_num=7;%攻击策略数量
DP_num=9;%防守策略数量
State_num = 4;%状态数量

%初始化收益矩阵
revenue_Matrix = fun_create_revenueM();

%初始化状态转换概率矩阵
state_trans_p = fun_create_stateP();

%初始化x下限向量
lb=zeros(1,32);
ub = zeros(1,32);
x0=rand(1,32);
for i=1:24
    lb(i)=0;
    ub(i)=1;
end
for i = 25:32
    lb(i)=-inf;
    ub(i)=inf;
    if i<29  
        x0(i)=2;
    else
        x0(i)=-2;
    end
end
%初始化x上限向量


[x,fval,exitflag,output] = fmincon(@(t) fun_obj(t),x0,[],[],[],[],lb,ub,@(t) fun_nonlcon(t));


end

function obj = fun_obj(x)
y=x;
tmpa=0;tmpd=0;

for i = 1:4
    [attacker,defender] = fun_c_con(y,i);
    tmpa = tmpa + attacker;
    tmpd = tmpd + defender;
end
obj = -tmpd;
end

function [c,ceq] = fun_nonlcon(x)
y=x;
for i = 1:4
  
  [attacker,defender] = fun_c_con(y,i);
  c(i) = attacker;%攻击方第i阶段收益约束条件
  c(i+4) = defender;%防守方第i阶段收益约束条件
  ceq(i) = y(3*i-2)+y(3*i-1)+y(3*i)-1;  %攻击方概率三个一组和为1
  ceq(i+4)=y(3*i-2+12)+y(3*i-1+12)+y(3*i+12)-1; %防守方概率三个一组和为1
end

end

function [attacker,defender] = fun_c_con(x,i)
%约束条件：将每阶段收益约束转变成矩阵形式约束，其中x是要求解的变量，i是传入的状态值1-4.
global revenue_Matrix state_trans_p State_num
attacker_reve_M = revenue_Matrix(:,:,i);
defender_reve_M = revenue_Matrix(:,:,i+4);
pa = [x(3*i-2),x(3*i-1),x(3*i)];
pd = [x(3*i-2+12),x(3*i-1+13),x(3*i+14)];
attacker_reve = pa*attacker_reve_M*pd';  %攻击方第i阶段收益
defender_reve = pa*defender_reve_M*pd'; %防守方第i阶段收益
%查看状态转换矩阵，列1代表向状态1转移的状态概率，以此类推,此时当前状态为i,补充完整收益目标函数
for  j = 1:State_num
    attacker_reve = attacker_reve + 0.7*state_trans_p(j,i)*x(j+24);
    defender_reve = defender_reve + 0.7*state_trans_p(j,i)*x(j+28);
end
attacker = attacker_reve-x(i+24);%返回约束函数 R-U-R‘>=0
defender = defender_reve-x(i+28);%返回约束函数

end


function revenue_Matrix = fun_create_revenueM()
%本次实践攻防双方分别4个收益矩阵，攻8个，其中1-4表示攻击方收益矩阵，5-8表示防守方收益矩阵
%收益矩阵为三位矩阵，维数分别为3*3*8
revenue_M = zeros(3,3,8);
revenue_M(:,:,1)=[2,5,5;10,8,8;7,9,2];
revenue_M(:,:,2)=[3,2.2,3.5;5.9,3,5.4;4,2,5];
revenue_M(:,:,3)=[3.2,5.9,2;3.4,4,1.5;2.5,2.4,1.8];
revenue_M(:,:,4)=[2,3,2;1.5,4,1.5;1,2.4,1.8];
revenue_M(:,:,5)=[3,2,2;5,3,3;1,3,5];
revenue_M(:,:,6)=[3,2.2,3.5;0,0,0;4,2,5];
revenue_M(:,:,7)=[3.2,5.9,2;3.4,4,1.5;2.5,2.4,1.8];
revenue_M(:,:,8)=[0,0,0;1.5,4,1.5;1,2.4,1.8];
% revenue_M(:,:,5)=[-2,-5,-5;-10,-8,-8;0,3,5];
% revenue_M(:,:,6)=[-3,-2.2,-3.5;-5.9,-3,-5.4;-4,-2,-5];
% revenue_M(:,:,7)=[-3.2,-5.9,-2;-3.4,-4,-1.5;-2.5,-2.4,-1.8];
% revenue_M(:,:,8)=[-2,-3,-2;-1.5,-4,-1.5;-1,-2.4,-1.8];
revenue_Matrix = revenue_M;
end

function state_tra_possibility  = fun_create_stateP()%状态转换
state_tra_possibility =[0,0.33,0.5,0;0.23,0,0.1,0.8;0.3,0.25,0,0.75;0,0.4,0.22,0];
end
