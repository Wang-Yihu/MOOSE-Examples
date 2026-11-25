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
  [./y]
    family = SCALAR
    order = FIRST
    initial_condition = 1.0
  []
[]

[AuxVariables]
  [nodex]
    family = LAGRANGE
    order = FIRST
    initial_condition = 2.0
  []
  [nodey]
    family = LAGRANGE
    order = FIRST
    initial_condition = 1.0
  []
[]

[AuxKernels]
  [cal_node_x]
    type = ConstantAuxCouple
    variable = nodex
    coupled_scalar_val = x
  []
  [cal_node_y]
    type = ConstantAuxCouple
    variable = nodey
    coupled_scalar_val = y
  []  
[]

[ScalarKernels]
  [./td_x]
    type = ODETimeDerivative
    variable = x
  [../]
  [./td_y]
    type = ODETimeDerivative
    variable = y
  [../]
  [./ode_x]
    type = ParsedODEKernel
    expression = '-(-2*x + y)'
    coupled_variables = 'y'
    variable =x
  [../]
  [./ode_y]
    type = ParsedODEKernel
    expression = '-(x - 2*y)'
    coupled_variables = x
    variable = y
  [../]
[]

[Postprocessors]
  [output_x]
    type = ScalarVariable
    variable = x
    outputs = 'x_y_output'
  []
  [output_y]
    type = ScalarVariable
    variable = y
    outputs = 'x_y_output'
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
    file_base = '01_fullcouple'
  []
  exodus = true
[]
