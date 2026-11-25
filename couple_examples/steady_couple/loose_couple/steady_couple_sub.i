# Eq 1: x = 0.5*y + 1
# Eq 2: y = 0.25*x + 1
# In theory, y = 10/7 = 1.4285714285714285714285714285714, x = 12/7 = 1.7142857142857142857142857142857

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
    initial_condition = 1.0
  []
[]

[ScalarKernels]
  [./ode_y]
    type = ParsedODEKernel
    expression = '-((1/4)*sub_receive_x - y + 1)'
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
  type = Steady
#  type = Transient
 # solve_type = 'PJFNK'
[]

[Outputs]
  [x_y_output]
    type = CSV
    file_base = 'steady_couple_sub'
  []
  exodus = true
[]

