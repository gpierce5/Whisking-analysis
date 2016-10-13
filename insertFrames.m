
function data_new = insertFrames(data,f,n,s)

disp(['Inserting ',num2str(n),' frames after start frame ',num2str(s)])

temp1 = data(1:f(s)+100);
temp2 = data(f(s)+101:end);

temp3 = [temp1 nan(1,n) temp2];
%temp3(isnan(temp3)) = nanmean(temp3); %Puts means in instead of nans

data_new = temp3;

end
        