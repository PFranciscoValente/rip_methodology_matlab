%%-----------------------------------------------------------------------
% File to plot decision rules using tree normalized approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function visualize_treeNormalized(feat, virtual_negatives, virtual_positives, header)

    
    figure()
    
    feat_branch1 = feat;
    name_feat_branch1 = header{feat};
    vn_branch1 = virtual_negatives(1,feat_branch1);
    vp_branch1 = virtual_positives(1,feat_branch1);
    threshold_branch1 = round(mean([vn_branch1,vp_branch1]),2);
    
    txt = [name_feat_branch1, ' >= ', num2str(threshold_branch1)];
    axis([0 , 10, 0 ,10]);
    text(4,8.03,txt,'FontSize',10)
    
    feat_branch2_pos = virtual_negatives(5,feat);
    if ~isnan(feat_branch2_pos)
       name_feat_branch2_pos = header{feat_branch2_pos};
       vn_branch2_pos = virtual_negatives(3,feat);
       vp_branch2_pos = virtual_positives(3,feat);
       threshold_branch2_pos = round(mean([vn_branch2_pos,vp_branch2_pos]),2);
       
       txt = [name_feat_branch2_pos, ' >= ', num2str(threshold_branch2_pos)];
       text(6,3.97,txt,'FontSize',10)
       hold on
       plot([4 6],[8 4],'.-b')
    end
    
    feat_branch2_neg = virtual_positives(4,feat);
    if ~isnan(feat_branch2_neg)
       name_feat_branch2_neg = header{feat_branch2_neg};
       vn_branch2_neg = virtual_negatives(2,feat);
       vp_branch2_neg = virtual_positives(2,feat);
       threshold_branch2_neg = round(mean([vn_branch2_neg,vp_branch2_neg]),2);
       txt = [name_feat_branch2_neg, ' >= ', num2str(threshold_branch2_neg)];
       text(2,3.97,txt,'FontSize',10)
       hold on
       plot([4 2],[8 4],'.-b')
    end

end