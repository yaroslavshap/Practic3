clear all
close all
clc
N_grid = 5;
for z = 1 : N_grid
% ��������� ������ �����
N_(z) = 10*2^(z-1);
N = N_(z);
a = 0;
b = 1;
gamma = 1.4;
h = (b - a) / N;
x = a + h/2:h:b - h/2;
t = 0;
t_end = 0.2;
K = 0.1;
tetha = 0.5;
tau = 1e-5;
% ��������� ������� ������ ����
for i = 1:N
    if x(i) <= 0.5
        rho(i) = 1;
        P(i) = 1;
        u(i) = 0;
    else
        rho(i) = 0.125;
        P(i) = 0.1;
        u(i) = 0;
    end
end

% ������ ������� �������������� ���������� � �������
e = P ./ (rho .* (gamma - 1));

U = [rho
    rho .* u
    rho .* e + (rho .* u.^2) ./ 2];

while t <= t_end
    % ������������� �������. ����������
    % �������� � ������� 
    
    UGCell = [U(:,1) U(:,:) U(:,N)];
    
    dUdx = zeros(3, N);
    
    % �������������� �����������
    for j = 1:3
        Um = zeros(3, N);
        for i = 2:N
            Um(1, i) = tetha * 1/h * (UGCell(j, i) - UGCell(j, i-1));
            Um(2, i) = tetha * 1/(2 * h) * (UGCell(j,i+1) - UGCell(j, i-1));
            Um(3, i) = tetha * 1/h * (UGCell(j, i+1) - UGCell(j, i));
        end
        
        for i = 1:N
            if (Um(1, i) > 0 && Um(2, i) > 0 && Um(3, i) > 0)
                dUdx(j, i) = min([Um(1, i) Um(2, i) Um(3, i)]);
            end
            if (Um(1, i) < 0 && Um(2, i) < 0 && Um(3, i) < 0)
                dUdx(j, i) = max([Um(1, i) Um(2, i) Um(3, i)]);
                if dUdx(j,i) < 0
                    dUdx(j, i) = 0.0;
                end
            end
        end
    end
    
    for j = 1:3
        % ��������� ������� �����
        Ur(j, 1) = U(j, 1) - h/2 * dUdx(j, 1);
        Ul(j, 1) = U(j, 1);
        
        for i = 2:N
            Ur(j, i) = U(j, i) - h/2 * dUdx(j, i);
            Ul(j, i) = U(j, i-1) + h/2 * dUdx(j, i-1);
        end
        
        % ��������� ������� ������
        Ul(j, N+1) = U(j, N) + h/2 * dUdx(j, N);
        Ur(j, N+1) = U(j, N);
    end
    
    for i = 1:N+1
        Fr(1, i) = Ur(2, i);
        Fr(2, i) = 1/2 * (3 - gamma) * (Ur(2, i)^2 / Ur(1, i)) + (gamma - 1) * Ur(3, i);
        Fr(3, i) = gamma * (Ur(2, i) / Ur(1, i)) * Ur(3, i) - (1/2) * (gamma - 1) * (Ur(2, i)^3 / Ur(1, i)^2);
        
        Fl(1, i) = Ul(2, i);
        Fl(2, i) = 1/2 * (3 - gamma) * (Ul(2, i)^2 / Ul(1, i)) + (gamma - 1) * Ul(3, i);
        Fl(3, i) = gamma * (Ul(2, i) / Ul(1, i)) * Ul(3, i) - (1/2) * (gamma - 1) * (Ul(2, i)^3 / Ul(1, i)^2);
    end
    
    % �������� ��������������� ����������
    speedL = Ul(2,:) ./ Ul(1,:);
    speedR = Ur(2,:) ./ Ur(1,:);
    
    Pl = (gamma - 1) * (Ul(3,:) - 0.5 * (Ul(2,:).^2 / Ul(1,:)));
    Pr = (gamma - 1) * (Ur(3,:) - 0.5 * (Ur(2,:).^2 / Ur(1,:)));
    
    cl = ((gamma .* Pl) ./ Ul(1,:)).^(1/2);
    cr = ((gamma .* Pr) ./ Ur(1,:)).^(1/2);
    
    for i = 1:N+1
        % ������ ��������� ����������
        amax(i) = max([abs(speedL(i)+cl(i)) abs(speedL(i)-cl(i)) abs(speedR(i)+cr(i)) abs(speedR(i)-cr(i))]);
    end
    Flux  = zeros(3,N+1);
    % �������� ������� �� �������� �����
    for j = 1:3
        Flux(j, :) = (Fr(j, :) + Fl(j, :)) ./ 2 - amax ./ 2 .* (Ur(j, :) - Ul(j, :));
    end
    
    % �������� �������������� ���������� �� ����� ��������� ����
    for j = 1:3
        for i = 1:N
            dUdt(j, i) = (Flux(j, i+1) - Flux(j, i));
        end
    end
    
    % ���������� ������������� ��������� �� ������� ������� ������
    % temp = dUdt .* tau / h;
    U = U - dUdt .* tau / h;
    
    % ��������
    vel = U(2,:) ./ U(1,:);
    
    % ��������
    P = (gamma - 1) * (U(3,:) - 0.5 * (U(2,:).^2 ./ U(1,:)));
    
    % ����� �� ���� �� ����� �� �������
    if t + tau > t_end
        tau = t_end - t;
    else
        tau = (K * h) / max(amax);
    end
    
    % ��� �� �������
    t = t + tau;
    
    
    
end

% load Result.txt
% 
% figure(2);
% plot(Result(:,1),Result(:,2),'k:','linewidth',2); % ���������
% hold on
% figure(3);
% plot(Result(:,1),Result(:,4),'k:','linewidth',2); % ��������
% hold on
% figure(1);
% plot(Result(:,1),Result(:,3),'k:','linewidth',2); % C�������
% hold on
% grid on;

 
data = analyticSod(t_end,N);

norma(z) = h*sum(abs(U(1,:)-data.rho'));


end

for z = 1 :N_grid-1
   N__(z) = N_(z);
   
   order(z) = log2(norma(z)/norma(z+1));
end

figure(5);
plot(N__,order,'b-o','linewidth',2);
grid on;
hold on;

figure(4);
loglog(N_,norma,'b-o','linewidth',2);
grid on;
hold on;

% ���������� �������
figure(1);
plot(x,vel,'bo','MarkerSize',4);
hold on;
plot(data.x,data.u,'k','LineWidth',2);
xlabel('������������');
ylabel('��������');
title('��������� �������');
grid on

figure(2);
plot(x,U(1,:),'bo','MarkerSize',4);
hold on;
plot(data.x,data.rho,'k','LineWidth',2);
xlabel('������������');
ylabel('���������');
title('��������� �������');
grid on

figure(3);
plot(x,P,'bo','MarkerSize',4);
hold on
plot(data.x,data.P,'k','LineWidth',2);
xlabel('������������');
ylabel('��������');
title('��������� �������');
grid on


% time = 0.165;
% data = analyticSod(time);
% figure(4);
% % subplot(2,2,1),
% plot(data.x,data.rho,'-b','LineWidth',2);
% xlabel('x (m)');
% ylabel('Density (kg/m^3)');
% title('Plot of Density vs Position');
% grid on;
% figure(5);
% % subplot(2,2,2),
% plot(data.x,data.P,'-g','LineWidth',2);
% xlabel('x (m)');
% ylabel('Pressure (Pa)');
% title('Plot of Pressure vs Position');
% grid on;
% % subplot(2,2,3),
% figure(6);
% plot(data.x,data.u,'-r','LineWidth',2);
% xlabel('x (m)');
% ylabel('Velocity (m/s)');
% title('Plot of Velocity vs Position');
% grid on;
% figure(7);
% % subplot(2,2,4),
% plot(data.x,data.e,'-k','LineWidth',2);
% xlabel('x (m)');
% ylabel('Specific Internal Energy (J/kg)');
% title('Plot of Internal Energy vs Position');
% grid on;


