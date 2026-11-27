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
[]

[Executioner]
  type = Transient
  dt = 0.1    # 0.1, 1, 10, 100
  end_time = 10
  solve_type = 'PJFNK'
[]

[Outputs]
  [x_y_output]
    type = CSV
    file_base = '02_loosecouple_parent'
  []
  exodus = true
[]

[MultiApps]
  [02_loosecouple_micro]
    type = TransientMultiApp
    input_files = '02_loose_couple_sub.i'
    execute_on = timestep_end
  []
[]

[Transfers]  
  [push_pps_to_x]
    type = MultiAppPostprocessorToAuxScalarTransfer
    from_postprocessor = output_x
    to_aux_scalar = sub_receive_x
    to_multi_app = 02_loosecouple_micro
  []
  [pull_pps_to_y]
    type = MultiAppPostprocessorToAuxScalarTransfer
    from_postprocessor = output_y
    to_aux_scalar = parent_receive_y
    from_multi_app = 02_loosecouple_micro    
  []
[]
