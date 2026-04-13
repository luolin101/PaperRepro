function f = calculate_L(delta,alpha,rho,choice,risk,time,eis1,eis2)
f=prod(1./(1+exp(choice.*[((risk*8^alpha+(1-risk)*6.4^alpha).^(1/alpha)-(risk*15.40^alpha+(1-risk)*0.4^alpha).^(1/alpha)) 8-time*delta^(1/rho) 8-(eis1.^rho+delta.*(eis2.^rho)).^(1/rho)])),2);
end
