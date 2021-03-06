% * Copyright@yoursilver;Time@2019/10/09
% * 考察三种情形时技术冲击带来的影响：同时存在工资和价格名义刚性、只有工资刚性且价格灵活调整、只存在价格粘性且工资灵活调整。
% * 只有工资刚性且价格灵活调整
var yt ${\tilde{y}}$ //产出缺口
    yn ${y^n}$  //自然产出
    y ${y}$  //总产出
    w ${w}$  //实际工资
    wn ${\omega^n}$  //自然真实工资
    wt ${\tilde{\omega}_t}$  //工资缺口
    n ${n}$  //就业人数
    a ${a}$  //技术
    Pip ${\pi^p}$  //通货膨胀
    Piw ${\pi^w}$  //工资的通货膨胀
    i ${i}$  //名义利率
    rn ${r^n}$  //自然利率
    z ${z}$  //效用水平参数，是总需求冲击的载体
    v ${v}$;  //货币政策参数，是外生货币政策冲击的载体

varexo 
    e_a ${\epsilon_a}$  //外生技术冲击
    e_z ${\epsilon_z}$  //外生需求冲击
    e_v ${\epsilon_v}$;  //外生货币政策冲击

parameters 
    alpha ${\alpha}$  //资本份额
    beta ${\beta}$  //主观贴现率
    ew ${\epsilon^w}$  //劳动力市场中各类劳动的替代弹性，用于劳动者垄断竞争，存在工资刚性的情形。
    ep ${\epsilon^p}$  //产品市场各类产品的替代弹性，用于生产者垄断竞争，存在价格刚性的情形。
    kappaw ${\kappa^w}$ //NKPC（新凯恩斯模型菲利普斯曲线）参数
    kappap ${\kappa^p}$ //NKPC参数
    lambdaw ${\lambda^w}$
    lambdap ${\lambda^p}$
    mup ${\mu^p}$
    muw ${\mu^w}$
    phi ${\phi}$
    phi_pip ${\Phi_{\pi^p}}$
    phi_piw ${\Phi_{\pi^w}}$
    phi_y  ${\Phi_{y}}$ 
    psi_y ${\psi_{y}}$
    psi_ya ${\psi_{ya}}$
    rho ${\rho}$
    rho_v ${\rho_v}$
    rho_a ${\rho_a}$
    rho_z ${\rho_z}$
    sigma ${\sigma}$ 
    thetap ${\theta^p}$
    thetaw ${\theta^w}$;


alpha = 0.25;
beta = 0.99;
ew = 4.5;
ep = 9;
phi = 5;
sigma = 1;
thetap = 1e-9;
thetaw = 3/4;
phi_pip = 1.5;
phi_piw = 0;
phi_y = 0.5/4;
rho= 1;
rho_v = 0.5;
rho_a = 0.9;
rho_z = 0.5;
lambdap = (1-thetap)/thetap*(1-beta*thetap)*(1-alpha)/(1-alpha+alpha*ep);
lambdaw = (1-thetaw)/thetaw*(1-beta*thetaw)/(1+ew*phi);
kappap = (alpha)/(1-alpha)*lambdap;
kappaw = (sigma+phi/(1-alpha))*lambdaw;
mup = log((ep)/(ep-1));
muw = log((ew)/(ew-1));
psi_y = -(1-alpha)*(mup+muw-log(1-alpha))/((1-alpha)*sigma+alpha+phi);
psi_ya = (1+phi)/((1-alpha)*sigma+alpha+phi);
//psi_wa = (1-alpha*psi_ya)/(1-alpha);


model;
//1、代表性消费者跨期优化欧拉公式
yt = yt(1)-1/sigma*(i-Pip(1)-rn);
//2、利率规则：类似泰勒规则
i = rho+phi_pip*Pip+phi_piw*Piw+phi_y*yt+phi_y*psi_ya*a+v;
//3、NKPC之一：价格的菲利普斯曲线
Pip = beta*Pip(1)+kappap*yt+lambdap*wt;
//4、NKPC之二：工资的菲利普斯曲线
Piw = beta*Piw(1)+kappaw*yt-lambdaw*wt;
//5、自然利率
rn = rho-(1-rho_a)*psi_ya*sigma*a+(1-rho_z)*z;
//6、自然真实工资与自然产出的联立方程
wn = sigma*yn + phi*(yn-a)/(1-alpha) + muw;
wn = yn -(yn-a)/(1-alpha)- mup +log(1-alpha);
//7、由定义得出的工资缺口动态方程
wt = w-wn;
//8、生产函数
y = a+(1-alpha)*n;
//9、真实工资
w = w(-1)+Piw-Pip;
//10、总产出
y = yt+yn;
//11、AR(1)冲击
v = rho_v*v(-1)+ e_v;
a = rho_a*a(-1)+ e_a;
z = rho_z*z(-1)+ e_z;

end;


initval; 
yt = 0;
yn = psi_y;
y =  psi_y;
w = - alpha/(1-alpha)*psi_y+log(1-alpha)-mup;
wn = - alpha/(1-alpha)*psi_y+log(1-alpha)-mup;
wt = 0;
n = psi_y/(1-alpha);
a = 0;
v = 0;
Pip = 0;
Piw = 0;
i = rho;
rn = rho;
end;
steady;

check;

write_latex_static_model;
write_latex_dynamic_model;

shocks;
var e_v;  //货币政策冲击
stderr 0.25;
end;

stoch_simul(order=1, irf=16) yt Pip Piw w;
