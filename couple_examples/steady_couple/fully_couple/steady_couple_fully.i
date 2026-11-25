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
  [./y]
    family = SCALAR
    order = FIRST
    initial_condition = 1.0
  []
[]

[ScalarKernels]
  [./ode_x]
    type = ParsedODEKernel
    expression = '-(x - (1/2)*y - 1)'
    coupled_variables = 'y'
    variable = x
  [../]
  
  [./ode_y]
    type = ParsedODEKernel
    expression = '-(y - (1/4)*x - 1)'
    coupled_variables = 'x'
    variable = y
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  [x_y_output]
    type = CSV
    file_base = 'fully_couple'
  []
  exodus = true
[]
