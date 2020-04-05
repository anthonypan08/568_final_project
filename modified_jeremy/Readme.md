Modified the weight in line 160.


Increase the significance of the potential statistic objects.


please put **Frame2Model_jacobians.geom** it in **/semantic_suma/src/shader**





From line 160

    // Jeremy
      if( model_label == parking.w ||
          model_label == other_ground.w||
          model_label == building.w|| model_label == fence.w||
          model_label == vegetation.w||
          model_label == trunk.w || model_label == terrain.w||
          model_label == pole.w  || model_label == traffic_sign.w)
      {
        if(round(data_label) != round(model_label))
          {
            
          }
        else
	  {
		weight *= (1+(data_label_prob*model_label_prob));
		}
           
      }
      // Jeremy
      
    


**Comparison**
 
Please select a folder to see the comparison.

The name of the folder is the dataset used to evaluate.
