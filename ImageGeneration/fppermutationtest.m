function [pValues] = fppermutationtest(G1Data,G2Data,simulate,permutations)

% Produces p-values from a Fisher-Pitman permutation test of independent
% samples. 

% Input arguments
%
% G1Data - A column vector of data from the first independent sample
% G2Data - A column vector of data from the first independent sample
% simulate - set to 1 to simulate the full permutation test
% permutations - the number of permutations to run if simulation is chosen
% (default 50000)

% Check that the Groups are the same size
if any(size(G1Data,2)~=1) || size(G2Data,2)~=1;
    error('Data vectors must be column vectors')
end

%Revert to default number of permutations if unspecified
if nargin == 3
    permutations = 50000;
end

%Initialise variables
N(1) = size(G1Data,1);
N(2) = size(G2Data,1);
n = sum(N);

if simulate == 1    
    [~, idx] = sort(rand(n, permutations), 1);
    Allocation = idx <= N(1);
else 
    permutations = nchoosek(n,N(1));
    
    if permutations > 1000000
        check = input(['Running with ',num2str(permutations) ,' permutations. Continue? [Y/N]: '],'s');
        if check =='N'
            pValues = [];
            return
        end
    end
        
    D = 0:ones(1,n)*pow2(n-1:-1:0)';
    b = rem(floor(pow2(1-n:0)'*D),2);
    Allocation = logical(b(:,sum(b,1) == N(1)));
end

% Compute the statistic for all the permutations:

DataMatrix = [G1Data;G2Data]';

StatDist = DataMatrix*Allocation/N(1) - DataMatrix*(~Allocation)/N(2);
absStatDist = abs(StatDist);

% Critical value for given allocation

critvalue = mean(G1Data)-mean(G2Data);
abscritvalue = abs(critvalue);

pValues(1) = sum(StatDist>=critvalue,2);
pValues(2) = sum(StatDist<=critvalue,2);
pValues(3) = sum(absStatDist>=abscritvalue,2);

pValues = pValues/permutations;
end