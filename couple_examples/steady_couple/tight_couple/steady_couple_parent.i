# Eq 1: x = 0.5*y + 1
# Eq 2: y = 0.25*x + 1
# In theory, y = 10/7 = 1.4285714285714285714285714285714, x = 12/7 = 1.7142857142857142857142857142857

[Mesh/generate]
  type = GeneratedMeshGenerator
  dim = 1
[]

[Variables]
  [./x]
    family = SCALAR
    order = FIRST
    initial_condition = 1.0
  []
[]

[AuxVariables]
  [parent_receive_y]
    family = SCALAR
    order = FIRST
    initial_condition = 1.0
  []
[]

[AuxScalarKernels]
  [cal_cal_from_sub_pps_y]
    type = FunctionScalarAux
    function = cal_from_sub_pps_y
    variable = parent_receive_y
  []
[]

[ScalarKernels]
  [./ode_x]
    type = ParsedODEKernel
    expression = '-(x - (1/2)*parent_receive_y - 1)'
    coupled_variables = 'parent_receive_y'
    variable = x
  [../]
[]

[Postprocessors]
  [output_x]
    type = ScalarVariable
    variable = x
    outputs = 'x_y_output'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  
  [from_sub_pps_y]
    type = Receiver
    default = 1.0
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Functions]
  [cal_from_sub_pps_y]
    type = ParsedFunction
    expression = 'from_sub_pps_y'
    symbol_names = 'from_sub_pps_y'
    symbol_values = 'from_sub_pps_y'
  []
[]

[Executioner]
  type = Steady
#  type = Transient
#  solve_type = 'PJFNK'
#  num_steps = 1
  accept_on_max_fixed_point_iteration = True
  fixed_point_max_its = 6
  fixed_point_min_its = 6
  relaxation_factor = 0.7
  transformed_postprocessors = from_sub_pps_y
[]

[Outputs]
  [x_y_output]
    type = CSV
    file_base = 'steady_couple_parent'
  []
  exodus = true
[]

[MultiApps]
  [steady_couple_micro]
    type = FullSolveMultiApp
#    type = TransientMultiApp
    input_files = 'steady_couple_sub.i'
    execute_on = timestep_end
  []
[]

[Transfers]  
  [push_pps_to_x]
    type = MultiAppPostprocessorToAuxScalarTransfer
    from_postprocessor = output_x
    to_aux_scalar = sub_receive_x
    to_multi_app = steady_couple_micro
  []

  [pull_pps_to_y_pps]
    type = MultiAppPostprocessorTransfer
    from_postprocessor = output_y
    to_postprocessor = from_sub_pps_y
    from_multi_app = steady_couple_micro
    reduction_type = average
  []
[]
