# S.A.P.O. — Product Backlog

**Proyecto:** Sistema Avanzado Policial Operativo  
**Repositorio:** `Zanguango/SAPO`  
**Estado:** backlog inicial de planificación académica  
**Base de alcance:** Propuesta preliminar de 47GIIN.  
**Nota:** S.A.P.O. es un prototipo académico con datos ficticios y escenario policial simulado. No se conecta con sistemas policiales, judiciales ni administrativos reales. «Avanzado» alude a la integración funcional, no a inteligencia artificial ni a capacidades predictivas.

## 1. Visión del producto

Integrar información ficticia de personas, antecedentes e incidencias para facilitar el registro y consulta de actuaciones en un entorno académico controlado, con autenticación, integridad y trazabilidad adecuadas al prototipo.

## 2. Alcance del incremento práctico de la asignatura

La implementación se limita aproximadamente al 20 % del producto: **un único circuito operativo de registrar y consultar incidencias asociadas a personas**.

Incluido en el incremento:
- Configuración del proyecto, arquitectura y conexión con PostgreSQL.
- Persistencia y datos de prueba ficticios.
- Autenticación básica con al menos dos perfiles de prueba y permisos.
- Alta, listado, consulta y actualización de personas mediante identificador.
- Alta, listado, detalle y actualización de estado de incidencias.
- Asociación de personas con incidencias.
- Validaciones e integración de los componentes.
- Consulta básica de antecedentes ficticios únicamente si resulta necesaria para el flujo de incidencias.

Fuera del compromiso de implementación de este incremento (visión futura del producto):
- Gestión completa de antecedentes.
- Gestión CRUD de organización y unidades.
- Automatización programada de seguimientos y avisos.
- Informes y estadísticas avanzadas.
- Auditoría avanzada y consultas específicas de auditoría.
- Administración completa de usuarios y perfiles.
- Filtros avanzados.
- Copias y recuperación completas como módulo funcional.

## 3. Backlog del producto

Prioridad orientativa: **Alta** = necesaria para el incremento práctico; **Media** = apoyo o calidad del incremento; **Futura** = visión de producto no comprometida para esta entrega.

| ID | Elemento del backlog | Prioridad | Alcance |
|---|---|---|---|
| SAPO-001 | Preparar repositorio, estructura y arquitectura del proyecto | Alta | Incremento |
| SAPO-002 | Configurar conexión del backend con PostgreSQL | Alta | Incremento |
| SAPO-003 | Definir el esquema de persistencia necesario para personas e incidencias | Alta | Incremento |
| SAPO-004 | Implementar inicio de sesión | Alta | Incremento |
| SAPO-005 | Aplicar permisos básicos según perfil | Alta | Incremento |
| SAPO-006 | Registrar una persona ficticia | Alta | Incremento |
| SAPO-007 | Listar, consultar y buscar personas por identificador | Alta | Incremento |
| SAPO-008 | Actualizar los datos permitidos de una persona | Alta | Incremento |
| SAPO-009 | Archivar una persona | Futura | Producto completo |
| SAPO-010 | Consultar antecedentes ficticios asociados a una persona, si el flujo lo requiere | Media | Incremento condicionado |
| SAPO-011 | Gestionar antecedentes mediante operaciones completas | Futura | Producto completo |
| SAPO-012 | Registrar una incidencia ficticia | Alta | Incremento |
| SAPO-013 | Asociar una o varias personas a una incidencia | Alta | Incremento |
| SAPO-014 | Listar y consultar incidencias | Alta | Incremento |
| SAPO-015 | Actualizar el estado de una incidencia | Alta | Incremento |
| SAPO-016 | Mostrar la ficha integrada de una incidencia y sus personas relacionadas | Media | Incremento |
| SAPO-017 | Gestionar organización y unidades | Futura | Producto completo |
| SAPO-018 | Detectar incidencias pendientes de revisión | Futura | Producto completo |
| SAPO-019 | Generar avisos de seguimiento sin duplicados | Futura | Producto completo |
| SAPO-020 | Generar informes de incidencias por periodo y estado | Futura | Producto completo |
| SAPO-021 | Generar informes de actividad por tipo | Futura | Producto completo |
| SAPO-022 | Consultar estadísticas agregadas | Futura | Producto completo |
| SAPO-023 | Registrar eventos de auditoría | Futura | Producto completo |
| SAPO-024 | Consultar el histórico de auditoría | Futura | Producto completo |
| SAPO-025 | Administrar usuarios y perfiles | Futura | Producto completo |
| SAPO-026 | Incorporar filtros avanzados de búsqueda | Futura | Producto completo |
| SAPO-027 | Verificar el flujo mediante pruebas funcionales y de integración | Alta | Incremento |
| SAPO-028 | Documentar instalación, configuración y uso del prototipo | Media | Incremento |
| SAPO-029 | Definir procedimientos completos de copia y recuperación | Futura | Producto completo |
| SAPO-030 | Revisar seguridad, privacidad y tratamiento de datos ficticios | Alta | Incremento |

## 4. Desglose técnico orientativo

Las tareas técnicas se concretarán al preparar cada iteración y se vincularán a los elementos anteriores:
1. Inicializar estructura del proyecto y control de versiones.
2. Configurar variables de entorno y conexión a base de datos.
3. Crear tablas, relaciones y restricciones necesarias para el incremento.
4. Preparar datos ficticios de prueba.
5. Implementar autenticación y autorización básica.
6. Implementar operaciones de personas.
7. Implementar operaciones de incidencias.
8. Implementar relación entre personas e incidencias.
9. Implementar validaciones de entrada y reglas de negocio.
10. Integrar interfaz, API y persistencia.
11. Ejecutar pruebas funcionales y de integración.
12. Corregir defectos detectados.
13. Documentar instalación y ejecución.
14. Revisar seguridad básica y coherencia del incremento.

## 5. Criterios generales de aceptación

- El sistema utiliza exclusivamente datos ficticios.
- Las operaciones del incremento persisten correctamente en PostgreSQL.
- Las entradas se validan antes de modificar datos.
- El acceso a las funciones está limitado por autenticación y permisos básicos.
- Se puede completar el circuito de registrar una incidencia, asociarla a personas y consultar o actualizar su estado.
- Los errores se gestionan sin dejar datos en estados inconsistentes.
- Las pruebas verifican los flujos principales y sus casos de error.
- La documentación permite configurar y ejecutar el prototipo.

## 6. Tecnologías y organización previstas

- Backend: JavaScript con Node.js y Express.
- Frontend: HTML, CSS y JavaScript.
- Base de datos: PostgreSQL.
- Control de versiones: Git y GitHub.
- Seguimiento: backlog priorizado y tablero GitHub Projects.
- Organización: Scrum adaptado al trabajo individual, con planificación, priorización, revisión de incrementos y retrospectiva.

## 7. Gestión del alcance

Este documento diferencia la visión global de S.A.P.O. del incremento que se implementará en la asignatura. La prioridad y el alcance podrán ajustarse durante la planificación, pero cualquier ampliación deberá justificarse y no podrá desplazar el circuito operativo principal.

