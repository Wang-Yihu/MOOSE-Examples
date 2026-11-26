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
  [./y]
    family = SCALAR
    order = FIRST
    initial_condition = 1.0
  []
[]

[AuxVariables]
  [sub_receive_x]
    family = SCALAR
    order = FIRST
    initial_condition = 2.0
  []
[]

[ScalarKernels]
  [./td_x]
    type = ODETimeDerivative
    variable = y
  [../] 
  [./ode_x]
    type = ParsedODEKernel
    expression = '-(sub_receive_x - 2*y)'
    coupled_variables = 'sub_receive_x'
    variable = y
  [../]
[]

[Postprocessors]
  [output_y]
    type = ScalarVariable
    variable = y
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
    file_base = '03_tightcouple_sub'
  []
  exodus = true
[]
