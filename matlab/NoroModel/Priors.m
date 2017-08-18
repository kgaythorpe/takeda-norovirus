function [ PriorProbabilities ] = Priors(Param,theta,ReportingParam,Dispersion,k,d,damping,GermanPopulation,ContactMatrix,mu,ageGroupBreaks)
%%PRIORS takes proposed values of each parameter and returns sum of log prior probability

%INPUTS
%Param=vector including alpha, q,omega1,omega2,nu, delta, epsilon, sigma
%               and psi 
%theta=vector of susceptibility of recovered individuals per season
%ReportingParam= reporting baseline values with one value for 18-26 and
%                26-37
%Dispersion=Dispersion parameter for negative binomial likelihood
%k=degree of diagonalisation of contact matrix
%d=degree of assymmetry in contact matrix
%damping= damping(1) is scaling on damping for 0-37 year olds and
%         damping(2) is baseline reporting dampin factor- see CappedReporting
%GermanPopulation=Age group sizes for German Population
%ContactMatrix= contact matrix given current parameters
%mu=vector of death rates per age
%ageGroupBreaks=vectorof age group divisions

%OUTPUTS
%PriorProbabilities=sum of log prior probabilities 
%%
%seasonal forncing amplitude
omega1Prior = log(unifpdf(Param(3),0.01,0.5));

%seasonal forcing offest
omega2Prior = log(gampdf(Param(4),1,1));

%scaling of asymptomatic infectiousness
nuPrior = log(unifpdf(Param(5)));

%loss of immunity
if Param(6)<1 && Param(6)>1/(30*365)
    deltaPrior = log( normpdf(Param(6),1/(5.1*365), 5e-5)/(normcdf(1,1/(5.1*365), 5e-5)-normcdf(1/(30*365),1/(5.1*365), 5e-5)) );
else
    deltaPrior =log(0);
end
%deltaPrior = log( unifpdf(ParamVector(6),1/(30*365),1));

%proportion of symptomatic
if Param(8)<=1 && Param(8)>=0
    sigmaPrior = log(normpdf(Param(8),0.735415,0.0960897));    %from challenge study data and ASYMP_PROB program
else
    sigmaPrior=log(0);
end
% sigmaPrior = log(unifpdf(ParamVector(8)));


%recovery rate
if Param(10)<0.5 && Param(10)>1/365
    gammaPrior = log( gampdf(Param(10),1,1)/(gamcdf(0.5,1,1)-gamcdf(1/365,1,1)) );
else
    gammaPrior=log(0);
end

%ReportingParam

for i=1:6
    if ReportingParam(i)<1 && ReportingParam(i)>0
        
        ReportingPrior(i)=log(normpdf(ReportingParam(i),1,0.1)/(normcdf(1,1,0.1)-normcdf(0,1,0.1)) );
    else
        ReportingPrior(i)=log(0);
    end
end

%Dispersion

DispersionPrior=log(unifpdf(Dispersion,0,0.4));

%k
if k<2
    kPrior=log( gampdf(k,1,1)/(gamcdf(2,1,1)-0) );
else
    kPrior=log(0);
end

%d
dPrior=log(unifpdf(d));


%theta
for i=1:9
    if theta(i)<1
        thetaPrior(i)=log(normpdf(theta(i),1,0.1)/(normcdf(1,1,0.1)-normcdf(0,1,0.1)) );
    else
        thetaPrior(i)=log(0);
    end
end

%damping
if damping(2)<1e-3 && damping(2)>9e-7
    dampPrior=[log(unifpdf(damping(1),0,1)),log(normpdf(damping(2),1e-3,1e-4)/(normcdf(1e-3,1e-3,1e-4)-normcdf(9e-7,1e-3,1e-4)))];
else
    dampPrior=log(0);
end

%prior on R0
R0=MakeR0( Param(1:10) ,GermanPopulation,ContactMatrix, mu, ageGroupBreaks);
if R0>1
    R0Prior=log(normpdf(R0,15,1));
else
    R0Prior=log(0);
end

%sum of log prior probabilities
PriorProbabilities=  omega1Prior + omega2Prior  +nuPrior+ deltaPrior+sigmaPrior + sum(ReportingPrior)+sum(thetaPrior) ...
    +sum(dampPrior) + gammaPrior+kPrior +dPrior+DispersionPrior + R0Prior;

end
