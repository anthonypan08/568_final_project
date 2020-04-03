Modified the weight in line 160.


Increase the significance of the potential statistic objects.


please put **Frame2Model_jacobians.geom** it in **/semantic_suma/src/shader**





From line 160

    // Jeremy
      if( model_label == road.w || model_label == parking.w ||
          model_label == sidewalk.w || model_label == other_ground.w||
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
	    if(data_label_prob>0.8) //feel free to change constant, 0.8
              {weight *= (1.3*data_label_prob);} // feel free to change the constant, 1.3
		}
      }
    // Jeremy
    
If the probability of potential statistic objects is higher than a threshold (0.8), we inrease the corresponding weight.




**Comparison**

Please select a folder to see the comparison.

The name of the folder is the dataset used to evaluate.
