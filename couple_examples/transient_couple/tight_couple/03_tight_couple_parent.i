# dx/dt = -2*x + y
# dy/dt =  x - 2*y
# x(0) = 2
# y(0) = 1
# In thoery:
# x(t) = 3/2*exp(-t) + 1/2*exp(-3t)
# y(t) = 3/2*exp(-t) - 1/2*exp(-3t)

[Mesh/generate]
  type = GeneratedMeshGenerator
  dim = 1
[]

[Variables]
  [./x]
    family = SCALAR
    order = FIRST
    initial_condition = 2.0
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
  [./td_x]
    type = ODETimeDerivative
    variable = x
  [../]

  [./ode_x]
    type = ParsedODEKernel
    expression = '-(-2*x + parent_receive_y)'
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
  type = Transient
  dt = 0.1    # 0.1, 1, 10, 100
  end_time = 2
  solve_type = 'PJFNK'
  accept_on_max_fixed_point_iteration = True
  fixed_point_max_its = 3
  fixed_point_min_its = 3
  relaxation_factor = 0.3
  transformed_postprocessors = from_sub_pps_y
[]

[Outputs]
  [x_y_output]
    type = CSV
    file_base = '03_tightcouple_parent'
  []
  exodus = true
[]

[MultiApps]
  [03_tightcouple_micro]
    type = TransientMultiApp
    input_files = '03_tight_couple_sub.i'
    execute_on = timestep_end
  []
[]

[Transfers]  
  [push_pps_to_x]
    type = MultiAppPostprocessorToAuxScalarTransfer
    from_postprocessor = output_x
    to_aux_scalar = sub_receive_x
    to_multi_app = 03_tightcouple_micro
  []

  [pull_pps_to_y_pps]
    type = MultiAppPostprocessorTransfer
    from_postprocessor = output_y
    to_postprocessor = from_sub_pps_y
    from_multi_app = 03_tightcouple_micro
    reduction_type = average
  []
[]
