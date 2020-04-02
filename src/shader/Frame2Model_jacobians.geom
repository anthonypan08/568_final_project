#version 330 core

/**
 *  \author behley
 *
 *  \author Xieyuanli Chen
 **/

layout(points) in;
layout(points, max_vertices = 16) out;

uniform sampler2DRect vertex_model;
uniform sampler2DRect normal_model;

uniform sampler2DRect vertex_data;
uniform sampler2DRect normal_data;

uniform sampler2DRect semantic_model; // [0,width]
uniform sampler2DRect semantic_data;

uniform float distance_thresh;
uniform float angle_thresh;

uniform mat4 pose;
uniform float fov_up;
uniform float fov_down;
uniform int entries_per_kernel;

const float pi = 3.14159265358979323846f;
const float inv_pi = 0.31830988618379067154f;
const float pi_2 = 1.57079632679;

uniform int iteration;
uniform int weight_function; // 0 - none, 1 - huber, 2 - turkey, 3 - stability.
uniform float factor;

uniform float cutoff_threshold;

#include "shader/color_map.glsl"

in VS_OUT {
  vec2 texCoords;
} gs_in[];

out vec3 values;

vec2 mat_coords(int i, int j)
{
  // keep in mind that we only have OpenGLs coord system...
  return vec2(2.0 * (j + 0.5) / 2.0 - 1.0, 2.0 * (i + 0.5) / 8.0 - 1.0);
}

vec2 project2model(vec4 vertex)
{
  vec2 tex_dim = textureSize(vertex_model);
  float fov = abs(fov_up) + abs(fov_down);
  float depth = length(vertex.xyz);
  float yaw = atan(vertex.y, vertex.x);
  float pitch = -asin(vertex.z / depth); // angle = acos((0,0,1) * p/||p||) - pi/2 = pi/2 - asin(x) + pi/2

  float x = 0.5 * ((-yaw * inv_pi) + 1.0); // in [0, 1]
  float y = 1.0 - (degrees(pitch) + fov_up) / fov; // in [0, 1]

  return vec2(x, y)*tex_dim; // [0, w],  [0, h]
}

void main()
{
  float c[400];
  int m[82];
  c[0]=0.0; c[1]=0.0; c[2]=0.0; c[3]=0.0; c[4]=0.0; c[5]=0.0; c[6]=0.0; c[7]=0.0; c[8]=0.0; c[9]=0.0; c[10]=0.0; c[11]=0.0; c[12]=0.0; c[13]=0.0; c[14]=0.0; c[15]=0.0; c[16]=0.0; c[17]=0.0; c[18]=0.0; c[19]=0.0; c[20]=0.08531506412092286; c[21]=0.7946592984003357; c[22]=0.00017804240995860493; c[23]=0.0015535842992197338; c[24]=0.0039304151307094646; c[25]=0.02560027858493013; c[26]=0.00040606025891308945; c[27]=0.00018236192144855786; c[28]=1.6099997371642706e-05; c[29]=0.009522873567322754; c[30]=0.001821812873317053; c[31]=0.007809284090972158; c[32]=2.8246987258540615e-05; c[33]=0.01667334053007579; c[34]=0.0027570525580356475; c[35]=0.03887036763807331; c[36]=0.001147419324876585; c[37]=0.008919529438177634; c[38]=0.0005138124364442787; c[39]=9.505543163647913e-05; c[40]=0.058511939203416824; c[41]=0.001562863499979122; c[42]=0.4630549805835088; c[43]=0.0016404101621918265; c[44]=0.0; c[45]=0.005988988373965796; c[46]=0.001694096312954468; c[47]=0.0003280820324383653; c[48]=0.00035194254388842827; c[49]=0.0016165496507417638; c[50]=0.00013123281297534612; c[51]=0.20889281261743844; c[52]=0.0007396758549519509; c[53]=0.11137490232103125; c[54]=0.0370434440262227; c[55]=0.05298226567486474; c[56]=0.00019684921946301918; c[57]=0.051663972417248766; c[58]=0.002213062436993337; c[59]=1.1930255725031467e-05; c[60]=0.061027856945849036; c[61]=0.01192117924672857; c[62]=0.04197542214458644; c[63]=0.6149796206061721; c[64]=0.0; c[65]=0.07951641077502988; c[66]=0.0011369556556648586; c[67]=0.0008764671631270877; c[68]=0.013493303913456529; c[69]=0.01935276271030615; c[70]=0.029996016058349423; c[71]=0.0307958689589654; c[72]=0.00011951824951733014; c[73]=0.020872789678526554; c[74]=0.008801446477276209; c[75]=0.035187398486102174; c[76]=2.4516564003554902e-05; c[77]=0.028430020532622353; c[78]=0.0012717967576844106; c[79]=0.0002206490760319941; c[80]=0.08948714554060873; c[81]=0.030177615837875902; c[82]=4.604926119716567e-05; c[83]=0.0007406256175877478; c[84]=0.5412706909883515; c[85]=0.2890608061306916; c[86]=7.866748787849135e-05; c[87]=5.7561576496457085e-06; c[88]=0.0; c[89]=0.007360206914680313; c[90]=0.00021105911382034265; c[91]=0.016119160138224533; c[92]=0.0; c[93]=0.00910816012095606; c[94]=0.000592884237913508; c[95]=0.007471492629240129; c[96]=0.0018400517286700782; c[97]=0.005712027107665091; c[98]=0.0005545098535825366; c[99]=0.0001630911334066284; c[100]=0.26904691403404873; c[101]=0.0826670955094039; c[102]=0.0007147378954032143; c[103]=0.0072818177486436994; c[104]=0.050010380717052286; c[105]=0.5283180855915647; c[106]=3.1482502535617775e-05; c[107]=9.019311537231037e-05; c[108]=0.00014464933597446003; c[109]=0.006904878596663195; c[110]=0.004375216974003962; c[111]=0.012297746193169829; c[112]=3.1482502535617775e-05; c[113]=0.010056532364012606; c[114]=0.0027134513671914886; c[115]=0.0186852906941126; c[116]=0.0009972295397768656; c[117]=0.0047019542976168595; c[118]=0.0006126324817741837; c[119]=0.00031822853914381205; c[120]=0.15441182136939852; c[121]=0.004369437059299503; c[122]=0.0032077216506762223; c[123]=0.0007879628559318768; c[124]=2.6971833699379646e-05; c[125]=0.0003255885639425115; c[126]=0.5227295495703772; c[127]=0.05032751512349247; c[128]=0.014468462220167226; c[129]=0.016107964397179517; c[130]=0.000712827033483605; c[131]=0.04886332986552614; c[132]=9.247485839787308e-05; c[133]=0.0465129272145802; c[134]=0.018785882171617925; c[135]=0.08703810734789813; c[136]=0.006823873925943051; c[137]=0.015574307401841792; c[138]=0.0031248795900281276; c[139]=0.005708395946518707; c[140]=0.09255125573916172; c[141]=0.019481412521422676; c[142]=0.0002486088483591816; c[143]=5.818504961597867e-05; c[144]=0.0013091636163595202; c[145]=0.0002300954234813702; c[146]=0.021166134185303515; c[147]=0.6183007849692148; c[148]=0.008341620294945305; c[149]=0.09632270486427015; c[150]=0.0003067938979751603; c[151]=0.03359922137824514; c[152]=3.4382074773078304e-05; c[153]=0.009042485665319594; c[154]=0.0021449125108435776; c[155]=0.0316050610414066; c[156]=0.00200473943676872; c[157]=0.06292184160971584; c[158]=0.00031208344794024924; c[159]=1.8513424877811397e-05; c[160]=0.007689047647877944; c[161]=0.0012108736453351092; c[162]=0.0; c[163]=0.0; c[164]=0.0; c[165]=0.0; c[166]=0.011866561724284071; c[167]=0.7790155597263425; c[168]=0.0; c[169]=0.17400254283465522; c[170]=0.0; c[171]=0.007144154507477145; c[172]=0.0; c[173]=0.0; c[174]=0.0; c[175]=0.0023006599261367077; c[176]=0.0006054368226675546; c[177]=0.01616516316522371; c[178]=0.0; c[179]=0.0; c[180]=0.0028222420799283486; c[181]=0.0007540777050091795; c[182]=1.1435989399432498e-07; c[183]=6.4842059894782265e-06; c[184]=1.5632997509024225e-05; c[185]=2.6348519576292475e-05; c[186]=7.0102615018521215e-06; c[187]=2.0870680653964308e-05; c[188]=0.0; c[189]=0.9698592377229193; c[190]=0.011774151605973717; c[191]=0.010760305401756428; c[192]=0.001052408360472175; c[193]=7.433393109631124e-07; c[194]=6.815849682061769e-06; c[195]=0.0002613581017346303; c[196]=1.2579588339375748e-07; c[197]=0.0026286993953323528; c[198]=2.756073445263232e-06; c[199]=6.175434275693549e-07; c[200]=0.003812784147512181; c[201]=0.012845788277273633; c[202]=0.0; c[203]=0.000172073393830716; c[204]=6.226339908348277e-05; c[205]=0.0011521558984948106; c[206]=3.3961854045536053e-06; c[207]=1.1320618015178685e-06; c[208]=0.0; c[209]=0.0394608442464091; c[210]=0.8523618771395968; c[211]=0.06630599177670307; c[212]=0.0003427317104095347; c[213]=6.45275226865185e-05; c[214]=4.499945661033527e-05; c[215]=0.0007480098353529316; c[216]=2.1792189679218967e-05; c[217]=0.022537369360068105; c[218]=6.226339908348277e-05; c[219]=0.0; c[220]=0.005704026816024398; c[221]=0.0006138568543977059; c[222]=0.00010353333145945622; c[223]=1.998694186464843e-05; c[224]=5.527613281301796e-06; c[225]=0.0002270049747546931; c[226]=6.0998266209790785e-05; c[227]=2.6908615973492616e-06; c[228]=1.0779656399019631e-05; c[229]=0.0333625664646867; c[230]=0.023965834616598746; c[231]=0.8865467424218773; c[232]=0.0013787423684490448; c[233]=0.002237613518292137; c[234]=0.00198068486577415; c[235]=0.008992373158052553; c[236]=2.0910912413135827e-05; c[237]=0.034581056678006865; c[238]=0.00018406465926446304; c[239]=1.0050205966003266e-06; c[240]=0.04737232383922121; c[241]=0.00025668327185610524; c[242]=3.8027151386089666e-05; c[243]=3.327375746282846e-05; c[244]=2.376696961630604e-05; c[245]=7.605430277217933e-05; c[246]=0.0011455679355059512; c[247]=4.753393923261208e-06; c[248]=0.0; c[249]=0.06483153971935962; c[250]=0.001506825873673803; c[251]=0.2595685819675248; c[252]=0.006573943795870251; c[253]=0.0687673498878199; c[254]=0.017521010001140813; c[255]=0.04639787808495266; c[256]=0.004739133741491425; c[257]=0.48078202836825495; c[258]=0.00032323078678176217; c[259]=3.8027151386089666e-05; c[260]=0.04569694791697828; c[261]=0.0005478658632712358; c[262]=0.00023764780960697595; c[263]=8.911568545708998e-05; c[264]=3.678758662646687e-06; c[265]=0.003034706719220396; c[266]=0.0005312845315430137; c[267]=1.686845435555066e-06; c[268]=6.280807472811417e-07; c[269]=3.327033444169247e-05; c[270]=2.0654884003445544e-05; c[271]=0.0022529974211542873; c[272]=0.0001668003013136632; c[273]=0.8773680416257464; c[274]=0.03625885030824139; c[275]=0.02860351503775151; c[276]=0.0009598329979950406; c[277]=0.0035731334261182067; c[278]=0.0005348735643846203; c[279]=8.446788792720953e-05; c[280]=0.1899808219043959; c[281]=0.0018522711418004155; c[282]=0.0023356399266655082; c[283]=0.0021977705922812756; c[284]=2.637447098073868e-05; c[285]=0.006795556850141602; c[286]=0.0016690572993031266; c[287]=2.392672425398799e-05; c[288]=2.1417783859068534e-05; c[289]=0.0008387816095892926; c[290]=0.0005452355833837162; c[291]=0.02321088072374975; c[292]=0.0006073471565750148; c[293]=0.048254328228149575; c[294]=0.5384462682877277; c[295]=0.15424365850016766; c[296]=0.0026564783288743547; c[297]=0.023631525998741857; c[298]=0.001802520689579208; c[299]=0.0008601381997801924; c[300]=0.05923371797074032; c[301]=0.0007216094098473623; c[302]=0.0004565366382912227; c[303]=0.00017611593924705734; c[304]=8.021279393941039e-05; c[305]=0.0008074844272345464; c[306]=0.0005906017021059484; c[307]=0.00012324813802734838; c[308]=3.509233300947372e-05; c[309]=0.00037402471258468173; c[310]=0.00020183441853575685; c[311]=0.004286217543994559; c[312]=0.0006798581553102154; c[313]=0.03504827650845729; c[314]=0.008318998613648003; c[315]=0.8241822202319242; c[316]=0.008934322096962752; c[317]=0.05442475980004304; c[318]=0.001025865256839067; c[319]=0.0002990033092577549; c[320]=0.13168794505695772; c[321]=0.0022724246920045868; c[322]=7.649775618841102e-05; c[323]=0.00011430530107383726; c[324]=6.693553666485966e-05; c[325]=0.0008375033191935077; c[326]=0.002353630002419977; c[327]=0.0003229087977568504; c[328]=0.0; c[329]=0.001271039641284368; c[330]=0.0002749505890695004; c[331]=0.003425334144405697; c[332]=0.0004425100973360392; c[333]=0.030708258889002492; c[334]=0.003685720737585481; c[335]=0.18493361980762285; c[336]=0.5541834342637864; c[337]=0.06064800955045064; c[338]=0.02053773509268365; c[339]=0.002157236724513191; c[340]=0.01840983767829464; c[341]=0.00013611684980327252; c[342]=0.00016994360784188946; c[343]=2.0717834848589323e-05; c[344]=9.616584579556933e-07; c[345]=8.514895153162077e-05; c[346]=4.067646565142415e-05; c[347]=8.401858106349742e-06; c[348]=4.386512264359303e-07; c[349]=0.006823692220839365; c[350]=0.004924484251180938; c[351]=0.04455086948012052; c[352]=0.0023895188136076966; c[353]=0.003697627384442691; c[354]=0.0022616182386995896; c[355]=0.05200346946126189; c[356]=0.0014255996147157566; c[357]=0.8626698409044057; c[358]=0.0003801419013097839; c[359]=8.941736538886271e-07; c[360]=0.17252476913455958; c[361]=0.00782159212323293; c[362]=0.0012531793949965367; c[363]=0.0004241530259988278; c[364]=0.0003424772780172353; c[365]=0.0005983712523801645; c[366]=0.0011648433928876899; c[367]=0.0003908517553625562; c[368]=3.855936599989344e-06; c[369]=0.00852512528288553; c[370]=0.0019339274747401099; c[371]=0.029567321848718287; c[372]=0.0005419343621439569; c[373]=0.060577114525523494; c[374]=0.01643996096390002; c[375]=0.1694193380128045; c[376]=0.013750970994943816; c[377]=0.047000712296651925; c[378]=0.4267168732981298; c[379]=0.041002627645523045; c[380]=0.3146254960787125; c[381]=0.001414855714475083; c[382]=0.0010875181591185152; c[383]=0.002396868380544787; c[384]=1.8936883367735337e-05; c[385]=0.001466255826473222; c[386]=0.0036385868756577187; c[387]=0.0006140960749251317; c[388]=0.0; c[389]=0.001820646072355126; c[390]=0.000405790357880043; c[391]=0.002340057730441581; c[392]=0.00011903183831147927; c[393]=0.01869070388395478; c[394]=0.0040227350811174924; c[395]=0.09403515226606862; c[396]=0.004704462882355965; c[397]=0.00827271276264781; c[398]=0.067350378331877; c[399]=0.4729757147997154; 
  m[0]=0; m[1]=-1; m[2]=-1; m[3]=-1; m[4]=-1; m[5]=-1; m[6]=-1; m[7]=-1; m[8]=-1; m[9]=-1; m[10]=1; m[11]=2; m[12]=-1; m[13]=-1; m[14]=-1; m[15]=3; m[16]=-1; m[17]=-1; m[18]=4; m[19]=-1; m[20]=5; m[21]=-1; m[22]=-1; m[23]=-1; m[24]=-1; m[25]=-1; m[26]=-1; m[27]=-1; m[28]=-1; m[29]=-1; m[30]=6; m[31]=7; m[32]=8; m[33]=-1; m[34]=-1; m[35]=-1; m[36]=-1; m[37]=-1; m[38]=-1; m[39]=-1; m[40]=9; m[41]=-1; m[42]=-1; m[43]=-1; m[44]=10; m[45]=-1; m[46]=-1; m[47]=-1; m[48]=11; m[49]=12; m[50]=13; m[51]=14; m[52]=-1; m[53]=-1; m[54]=-1; m[55]=-1; m[56]=-1; m[57]=-1; m[58]=-1; m[59]=-1; m[60]=-1; m[61]=-1; m[62]=-1; m[63]=-1; m[64]=-1; m[65]=-1; m[66]=-1; m[67]=-1; m[68]=-1; m[69]=-1; m[70]=15; m[71]=16; m[72]=17; m[73]=-1; m[74]=-1; m[75]=-1; m[76]=-1; m[77]=-1; m[78]=-1; m[79]=-1; m[80]=18; m[81]=19;
  vec2 tex_dim = textureSize(vertex_data);
  vec2 model_dim = textureSize(vertex_model);

  bool has_inlier = false;

  // Idea: compute aggregated values, then submit values.

  // store Jacobian in column-major order; store J^T*f in last row.

  vec3 temp[16];
  for(int i = 0; i < 16; ++i) temp[i] = vec3(0);

  //calculate confusion prob
  float confusion_product = 0;
  float model_label_prob = 0;
  int data_label_back = 0;
  int model_label_back = 0;

  // for(int e = 0; e < entries_per_kernel; ++e)
  // {
  //   vec2 texCoords = gs_in[0].texCoords + vec2(e, 0);
  //   if(texCoords.x >= tex_dim.x || texCoords.y >= tex_dim.y) continue;

  //   vec2 img_coords = texCoords.xy / tex_dim;

  //   float e_d = texture(vertex_data, texCoords).w + texture(normal_data, texCoords).w;
  //   vec4 v_d = pose * vec4(texture(vertex_data, texCoords).xyz, 1.0);
  //   vec4 n_d = pose * vec4(texture(normal_data, texCoords).xyz, 0.0); // assuming non-scaling transform

  //   bool inlier = false;

  //   vec2 idx = project2model(v_d);
  //   if(idx.x < 0 || idx.x >= model_dim.x || idx.y < 0 || idx.y >= model_dim.y)
  //   {
  //     e_d = 0.0f;
  //   }

  //   float e_m = texture(vertex_model, idx).w + texture(normal_model, idx).w;
  //   vec3 v_m = texture(vertex_model, idx).xyz;
  //   vec3 n_m = texture(normal_model, idx).xyz;

  //   // Reminder: use ifs instead of if(...) return; to avoid problemns with Intel cpu.
  //   if((e_m > 1.5f) && (e_d > 1.5f))
  //   {
  //     confusion_product = 0;
  //     float data_label = texture(semantic_data, texCoords).x * 255.0;
  //     float data_label_prob = texture(semantic_data, texCoords).w;
  //     float model_label = texture(semantic_model, idx).x * 255.0;
  //     model_label_prob = texture(semantic_model, idx).w;
  //     data_label_back = m[int(round(data_label))];
  //     model_label_back = m[int(round(model_label))];
  //     if(data_label_back == -1 || model_label_back == -1){
  //       confusion_product = 0;
  //     }else{
  //       for(int label_i = 0; label_i < 20; ++label_i){
  //         confusion_product += c[data_label_back + label_i*20] * c[model_label_back + label_i*20];
  //       }
  //     }
  //   }
  // }

  for(int e = 0; e < entries_per_kernel; ++e)
  {
    vec2 texCoords = gs_in[0].texCoords + vec2(e, 0);
    if(texCoords.x >= tex_dim.x || texCoords.y >= tex_dim.y) continue;

    vec2 img_coords = texCoords.xy / tex_dim;

    float e_d = texture(vertex_data, texCoords).w + texture(normal_data, texCoords).w;
    vec4 v_d = pose * vec4(texture(vertex_data, texCoords).xyz, 1.0);
    vec4 n_d = pose * vec4(texture(normal_data, texCoords).xyz, 0.0); // assuming non-scaling transform

    bool inlier = false;

    vec2 idx = project2model(v_d);
    if(idx.x < 0 || idx.x >= model_dim.x || idx.y < 0 || idx.y >= model_dim.y)
    {
      e_d = 0.0f;
    }

    float e_m = texture(vertex_model, idx).w + texture(normal_model, idx).w;
    vec3 v_m = texture(vertex_model, idx).xyz;
    vec3 n_m = texture(normal_model, idx).xyz;

    // Reminder: use ifs instead of if(...) return; to avoid problemns with Intel cpu.
    if((e_m > 1.5f) && (e_d > 1.5f))
    {
      has_inlier = true;

      bool inlier = true;

      if(length(v_m.xyz - v_d.xyz) > distance_thresh) inlier = false;
      if(dot(n_m.xyz, n_d.xyz) < angle_thresh) inlier = false;

      float residual = (dot(n_m.xyz, (v_d.xyz - v_m.xyz)));
      vec3 n = n_m;
      vec3 cp = cross(v_d.xyz, n_m.xyz);

      float weight = 1.0;

      if((weight_function == 4 || weight_function == 1))
      {
        // huber weighting.
        if(abs(residual) > factor)
        {
          weight = factor / abs(residual);
        }
      }
      else if(weight_function == 2 && iteration > 0)
      {
        // turkey bi-squared weighting:
        if(abs(residual) > factor)
        {
          weight = 0;
        }
        else
        {
          float alpha = residual / factor;
          weight = (1.0  - alpha * alpha);
          weight = weight * weight;
        }
      }

      // use semantic information during ICP
      float data_label = texture(semantic_data, texCoords).x * 255.0;
      float data_label_prob = texture(semantic_data, texCoords).w;
      float model_label = texture(semantic_model, idx).x * 255.0;
      model_label_prob = texture(semantic_model, idx).w;

      // float confusion_product;
      // int data_label_back = m[int(data_label)];
      // int model_label_back = m[int(model_label)];
      // confusion_product = 0;
      // for(int label_i = 0; label_i < 20; ++label_i){
      //   confusion_product += c[data_label_back*20 + label_i] * c[model_label_back*20 + label_i];
      // }

      if( model_label == car.w || model_label == bicycle.w ||
          model_label == bus.w || model_label == motorcycle.w||
          model_label == truck.w|| model_label == other_vehicle.w||
          model_label == person.w||
          model_label == bicyclist.w || model_label == motorcyclist.w)
      {
        if(round(data_label) !=  round(model_label))
          weight *= 1 - data_label_prob;
        else
          weight *= data_label_prob;
      }

      // confusion_product = 0;
      // float data_label = texture(semantic_data, texCoords).x * 255.0;
      // float data_label_prob = texture(semantic_data, texCoords).w;
      // float model_label = texture(semantic_model, idx).x * 255.0;
      // model_label_prob = texture(semantic_model, idx).w;
      // data_label_back = m[int(round(data_label))];
      // model_label_back = m[int(round(model_label))];
      // if(data_label_back == -1 || model_label_back == -1){
      //   confusion_product = 0;
      // }else{
      //   for(int label_i = 0; label_i < 20; ++label_i){
      //     confusion_product += c[data_label_back*20 + label_i] * c[model_label_back*20 + label_i];
      //   }
      // }

      // if(round(data_label) != round(model_label)){
      //   confusion_product = (1 - data_label_prob) * model_label_prob + data_label_prob * (1 - model_label_prob);
      // }else{
      //   confusion_product = data_label_prob * model_label_prob + (1 - data_label_prob) * (1 - model_label_prob);
      // }


      if(inlier)
      {
        // weight *= confusion_product;
        temp[0] += weight * n.x * n;
        temp[1] += weight * n.y * n;
        temp[2] += weight * n.z * n;
        temp[3] += weight * cp.x * n;
        temp[4] += weight * cp.y * n;
        temp[5] += weight * cp.z * n;

        temp[6] += weight * n.x * cp;
        temp[7] += weight * n.y * cp;
        temp[8] += weight * n.z * cp;
        temp[9] += weight * cp.x * cp;
        temp[10] += weight * cp.y * cp;
        temp[11] += weight * cp.z * cp;

        // compute J^T * W * f => 2 vertices

        temp[12] += weight * residual * n;

        temp[13] += weight * residual * cp;

        temp[14].x += 1.0f; // terms in error function (inlier + outlier)
        temp[14].y += weight * residual * residual; // residual

        temp[15].x += weight * residual * residual; // inlier residual
      }
      else
      {
        // was cut-off due to gross outlier rejection.
        temp[14].x += 1.0f; // terms.
        temp[14].y += weight * residual * residual; // "outlier" residual.
        temp[14].z += 1.0f;// num_outliers.
      }
    }
    else
    {
      temp[15].y += 1.0; // invalid count.
    }
    
  }

  // SUBMISSION:
  if(iteration == 0){
    int debug = data_label_back;
    temp[15] = vec3(temp[15].x, temp[15].y, debug/960.0);
  }
  if(has_inlier)
  {
    for(int i = 0; i < 6; ++i)
    {
      gl_Position = vec4(mat_coords(i, 0), 0.0, 1.0);
      values = temp[i];

      EmitVertex();
      EndPrimitive();

      gl_Position = vec4(mat_coords(i, 1), 0.0, 1.0);
      values = temp[i + 6];

      EmitVertex();
      EndPrimitive();
    }
  }

  gl_Position = vec4(mat_coords(6, 0), 0.0, 1.0);
  values = temp[12];

  EmitVertex();
  EndPrimitive();

  gl_Position = vec4(mat_coords(6, 1), 0.0, 1.0);
  values = temp[13];

  EmitVertex();
  EndPrimitive();

  gl_Position = vec4(mat_coords(7, 0), 0.0, 1.0);
  values = temp[14];

  EmitVertex();
  EndPrimitive();

  gl_Position = vec4(mat_coords(7, 1), 0.0, 1.0);
  values = temp[15];

  EmitVertex();
  EndPrimitive();
}
