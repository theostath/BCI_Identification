function [ScoreMat] = CalcScoreMatrix(FCprofile_EO,FCprofile_EC,Ns,T,epoch)

% Calculate score matrix, where similarity scores = 1/(1+d), and d
% represents Euclidian distance.
%
% dimensions of score matrix: runs * epochs * subjects (2 * 5 * 109)
%
% Input: FCprofile = dianysma xaraktiristikwn
%        Ns = number of subjects
%        T = signal duration (sec)
%        epoch = duration of epochs in sec (non overlapping) (sec)

dim = 2*Ns*(T/epoch); % range: 1-1090

% Initialize matrix.
ScoreMat = zeros(dim,dim);

for i=1:dim
    
    % Arxika, prepei na orisw katallhla ta dianysmata metaksy twn opoiwn
    % tha ypologistoun oi Eykleideies apostaseis. Etsi, exw ena dianysma
    % gia EO (Eyes Open) kai ena gia EC (Eyes Closed) gia kathe diastash
    % tou pinaka ScoreMat, dhladh (x,y).
    
    % - Diastash x tou pinaka -
    % subject (range: 1-109)
    subj_x = fix((i+(T/epoch)-1)/(T/epoch));
    subj_x = mod(subj_x,Ns);   
    if (subj_x == 0)
        subj_x = Ns;
    end
    
    % epoch (range: 1-5)
    ep_x = mod(i,(T/epoch)) ;
    if (ep_x == 0)
        ep_x = T/epoch;
    end
        
    x_EO = FCprofile_EO(:,subj_x,ep_x); % dianysma gia EO
    x_EC = FCprofile_EC(:,subj_x,ep_x); % dianysma gia EC
        
    for j=1:dim
        
        % - Diastash y tou pinaka -
        % subject (range: 1-109)
        subj_y = fix((j+(T/epoch)-1)/(T/epoch));
        subj_y = mod(subj_y,Ns);
        if (subj_y == 0)
            subj_y = Ns;
        end
        
        % epoch (range: 1-5)
        ep_y = mod(j,(T/epoch)) ;
        if (ep_y == 0)
            ep_y = T/epoch;
        end
        
        if (i<j)
            y_EO = FCprofile_EO(:,subj_y,ep_y); % dianysma gia EO
            y_EC = FCprofile_EC(:,subj_y,ep_y); % dianysma gia EC
        
        % -- Ypologizw Eukleideies apostaseis kai score omoiothtas --
                    
            % case1: Task1 vs Task1 (EO vs EO)
            if ((i<=dim/2) && (j<=dim/2))
                prod1 = (x_EO-y_EO).*(x_EO-y_EO); % product (ginomeno)
                Euclidian1 = sum(sqrt(prod1));
                   
                
                ScoreMat(i,j) = 1/(1+Euclidian1) ;
                ScoreMat(j,i) = 1/(1+Euclidian1) ; % symmetric matrix

            % case3: Task2 vs Task2 (EC vs EC)
            elseif((i>dim/2) && (j>dim/2))
                prod3 = (x_EC-y_EC).*(x_EC-y_EC);
                Euclidian3 = sum(sqrt(prod3));
                
                ScoreMat(i,j) = 1/(1+Euclidian3) ;
                ScoreMat(j,i) = 1/(1+Euclidian3) ; % symmetric matrix
            
            % case2: Task1 vs Task2 (EO vs EC)
            else
                prod2 = (x_EO-y_EC).*(x_EO-y_EC);
                Euclidian2 = sum(sqrt(prod2));
                
                ScoreMat(i,j) = 1/(1+Euclidian2) ;
                ScoreMat(j,i) = 1/(1+Euclidian2) ;
            end        
        end
    end
end