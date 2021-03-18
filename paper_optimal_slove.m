function [x,fval,exitflag,output] = paper_optimal_slove()
%PAPER_OPTIMAL_ �˴���ʾ�йش˺�����ժҪ
%x(1)-x(12) ��������12������ֵ��״̬1������Ϊx1-x3��״̬2����Ϊ4-6,�Դ�����
%x(13)-x(24)���ط���12������ֵ
%x(25)-x(28)������1-4�׶�����ֵ
%x(29)-x(32)���ط�1-4�׶�����ֵ
%   �˴���ʾ��ϸ˵��
global AP_num DP_num State_num state_trans_p revenue_Matrix;%ȫ�ֱ���

AP_num=7;%������������
DP_num=9;%���ز�������
State_num = 4;%״̬����

%��ʼ���������
revenue_Matrix = fun_create_revenueM();

%��ʼ��״̬ת�����ʾ���
state_trans_p = fun_create_stateP();

%��ʼ��x��������
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
%��ʼ��x��������


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
  c(i) = attacker;%��������i�׶�����Լ������
  c(i+4) = defender;%���ط���i�׶�����Լ������
  ceq(i) = y(3*i-2)+y(3*i-1)+y(3*i)-1;  %��������������һ���Ϊ1
  ceq(i+4)=y(3*i-2+12)+y(3*i-1+12)+y(3*i+12)-1; %���ط���������һ���Ϊ1
end

end

function [attacker,defender] = fun_c_con(x,i)
%Լ����������ÿ�׶�����Լ��ת��ɾ�����ʽԼ��������x��Ҫ���ı�����i�Ǵ����״ֵ̬1-4.
global revenue_Matrix state_trans_p State_num
attacker_reve_M = revenue_Matrix(:,:,i);
defender_reve_M = revenue_Matrix(:,:,i+4);
pa = [x(3*i-2),x(3*i-1),x(3*i)];
pd = [x(3*i-2+12),x(3*i-1+13),x(3*i+14)];
attacker_reve = pa*attacker_reve_M*pd';  %��������i�׶�����
defender_reve = pa*defender_reve_M*pd'; %���ط���i�׶�����
%�鿴״̬ת��������1������״̬1ת�Ƶ�״̬���ʣ��Դ�����,��ʱ��ǰ״̬Ϊi,������������Ŀ�꺯��
for  j = 1:State_num
    attacker_reve = attacker_reve + 0.7*state_trans_p(j,i)*x(j+24);
    defender_reve = defender_reve + 0.7*state_trans_p(j,i)*x(j+28);
end
attacker = attacker_reve-x(i+24);%����Լ������ R-U-R��>=0
defender = defender_reve-x(i+28);%����Լ������

end


function revenue_Matrix = fun_create_revenueM()
%����ʵ������˫���ֱ�4��������󣬹�8��������1-4��ʾ�������������5-8��ʾ���ط��������
%�������Ϊ��λ����ά���ֱ�Ϊ3*3*8
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

function state_tra_possibility  = fun_create_stateP()%״̬ת��
state_tra_possibility =[0,0.33,0.5,0;0.23,0,0.1,0.8;0.3,0.25,0,0.75;0,0.4,0.22,0];
end
