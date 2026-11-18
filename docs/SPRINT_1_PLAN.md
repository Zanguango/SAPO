# Planificación del Sprint 1 — S.A.P.O.

**Asignatura:** Proyecto de Ingeniería de Software (47GIIN) — VIU  
**Proyecto:** S.A.P.O. — Sistema Avanzado Policial Operativo  
**Responsable:** Ignacio Teruel Cuartero  
**Fecha de planificación:** 18/11/2026  
**Periodo del sprint:** 18/11/2026–30/11/2026 (13 días naturales)  
**Repositorio:** https://github.com/Zanguango/SAPO  
**Tablero:** https://github.com/users/Zanguango/projects/1

## 1. Objetivo de la iteración

Preparar los cimientos técnicos y documentales del prototipo S.A.P.O. mediante la definición de la estructura lógica del repositorio y su arquitectura, la revisión del modelo de persistencia ya existente para ajustarlo al circuito práctico de personas e incidencias, la documentación inicial del entorno de trabajo y la definición de criterios básicos de seguridad, privacidad y tratamiento de datos ficticios.

El Sprint 1 no pretende entregar todavía una aplicación funcional ni implementar el backend. El resultado esperado es un incremento de diseño y preparación verificable que reduzca incertidumbres y permita iniciar en el Sprint 2 la implementación de la API Node.js/Express y su conexión con PostgreSQL.

## 2. Incremento esperado

Al cierre del sprint se espera disponer de:
- Estructura lógica del repositorio y documentación inicial de arquitectura cliente-servidor por capas.
- Modelo lógico de datos acotado al circuito práctico, con entidades, relaciones, claves y restricciones identificadas, reutilizando el esquema PostgreSQL que ya está creado.
- Guía inicial de requisitos, configuración y preparación del entorno, diferenciando los componentes instalados de los que todavía no están implementados.
- Checklist de seguridad básica y privacidad, con uso exclusivo de datos ficticios y sin conexión a sistemas institucionales reales.

**No forma parte del incremento de este sprint:** código funcional del backend, conexión Node.js/Express–PostgreSQL, autenticación implementada, operaciones CRUD o pruebas de integración. Estas actividades se planifican para iteraciones posteriores. La base de datos PostgreSQL y el esquema SQL existentes se revisan y documentan; no se considera necesario recrearlos.

## 3. Plazos

- **Inicio:** miércoles 18 de noviembre de 2026.
- **Finalización:** lunes 30 de noviembre de 2026.
- **Duración:** 13 días naturales, dentro del intervalo de 7 a 21 días indicado por la asignatura.

## 4. Sprint Backlog

| ID | Historia de usuario | Prioridad | Estimación |
|---|---|---|---:|
| SAPO-001 | Preparar repositorio, estructura y arquitectura del proyecto | Alta | 4 h |
| SAPO-003 | Definir el esquema de persistencia necesario para personas e incidencias | Alta | 4 h |
| SAPO-028 | Documentar instalación, configuración y uso del prototipo | Media | 3 h |
| SAPO-030 | Revisar seguridad, privacidad y tratamiento de datos ficticios | Alta | 3 h |
| **Total** | **4 historias de usuario** |  | **14 h** |

Las estimaciones representan esfuerzo de trabajo individual, no duración natural de las historias. Se revisarán durante el sprint a medida que se conozca mejor el trabajo.

## 5. Descomposición en tareas técnicas y estimaciones

### SAPO-001 — Preparar repositorio, estructura y arquitectura del proyecto (4 h)

- [ ] **T1 (0,5 h):** Revisar el estado actual del repositorio y los documentos ya disponibles.
- [ ] **T2 (1 h):** Definir y documentar la estructura lógica de carpetas para documentación, backend, frontend, base de datos y pruebas.
- [ ] **T3 (1,5 h):** Describir la arquitectura por capas (interfaz web, API REST, persistencia), responsabilidades y comunicaciones; preparar un esquema de componentes.
- [ ] **T4 (1 h):** Actualizar el README, enlazar la documentación y revisar coherencia y versionado.

### SAPO-003 — Definir el esquema de persistencia necesario para personas e incidencias (4 h)

- [ ] **T1 (0,75 h):** Inspeccionar el esquema PostgreSQL existente y localizar tablas, claves, restricciones y relaciones candidatas.
- [ ] **T2 (0,75 h):** Seleccionar las entidades necesarias para el circuito práctico: personas, incidencias, asociación y autenticación básica.
- [ ] **T3 (1,5 h):** Documentar claves primarias/foráneas, cardinalidades y relaciones relevantes mediante un modelo lógico o diagrama.
- [ ] **T4 (1 h):** Separar los elementos imprescindibles de los módulos futuros y registrar dudas o ajustes pendientes.

### SAPO-028 — Documentar instalación, configuración y uso del prototipo (3 h)

- [ ] **T1 (0,5 h):** Inventariar tecnologías previstas, herramientas instaladas y requisitos previos del entorno.
- [ ] **T2 (0,75 h):** Documentar PostgreSQL y la base de datos sapo_db ya creada, indicando qué configuración existe y qué debe verificarse.
- [ ] **T3 (0,75 h):** Preparar la plantilla de variables de entorno y los parámetros que necesitará el futuro backend, sin incluir secretos.
- [ ] **T4 (1 h):** Redactar instrucciones iniciales de preparación y ejecución, distinguiendo el entorno ya disponible del backend aún no implementado.

### SAPO-030 — Revisar seguridad, privacidad y tratamiento de datos ficticios (3 h)

- [ ] **T1 (0,5 h):** Definir las reglas de uso exclusivo de datos ficticios y la prohibición de conexiones a sistemas institucionales reales.
- [ ] **T2 (1 h):** Documentar requisitos de autenticación y permisos diferenciados para los dos perfiles de prueba.
- [ ] **T3 (0,75 h):** Definir controles de validación de entradas, gestión de errores y protección de credenciales y secretos.
- [ ] **T4 (0,75 h):** Preparar una lista de comprobación de seguridad básica y documentar las limitaciones de prototipo/no producción.

## 6. Secuencia de trabajo prevista

| Fechas | Trabajo previsto |
|---|---|
| 18–20/11/2026 | Revisión del repositorio, estructura lógica y arquitectura inicial (SAPO-001). |
| 21–23/11/2026 | Inspección del esquema PostgreSQL existente y documentación del modelo de datos del circuito (SAPO-003). |
| 24–25/11/2026 | Documentación inicial del entorno y configuración, incluyendo situación actual y pendientes (SAPO-028). |
| 26–27/11/2026 | Requisitos básicos de seguridad, privacidad y datos ficticios (SAPO-030). |
| 28–29/11/2026 | Revisión cruzada, correcciones, trazabilidad y consolidación de entregables. |
| 30/11/2026 | Comprobación de criterios de aceptación, cierre del sprint y preparación del informe de avance y vídeo. |

La secuencia es orientativa y podrá ajustarse dentro del periodo sin alterar el objetivo ni el alcance comprometido.

## 7. Criterios de aceptación del Sprint 1

El sprint se considerará completado cuando:
1. La estructura de carpetas y la arquitectura inicial estén documentadas y versionadas.
2. El modelo de datos requerido por el circuito práctico esté identificado, con relaciones y restricciones relevantes documentadas, distinguiendo las entidades futuras.
3. La guía inicial de entorno describa con precisión PostgreSQL y la base sapo_db existentes, así como los componentes que quedan pendientes de implementación.
4. Exista una checklist de seguridad y privacidad con el uso exclusivo de datos ficticios y las limitaciones de no producción.
5. Los documentos estén revisados, enlazados desde el repositorio y disponibles para su evaluación.

## 8. Riesgos, dependencias y medidas

- **Revisión del Product Backlog por el profesor:** si la devolución modifica prioridades, historias o alcance, se analizará el impacto y se actualizará el Sprint Backlog con trazabilidad. Los cambios relevantes se documentarán usando el modelo de registro de cambios del aula virtual.
- **Complejidad del esquema de base de datos existente:** se limitará la revisión a las entidades y relaciones necesarias para el circuito de personas e incidencias; no se intentará rediseñar módulos futuros durante este sprint.
- **Backend todavía no implementado:** se deja fuera del Sprint 1 y se mantiene como trabajo de una iteración posterior. La documentación distinguirá claramente la configuración de PostgreSQL ya realizada de la futura conexión desde Node.js/Express.
- **Capacidad individual:** se han estimado 14 horas de esfuerzo; la secuencia conserva los días finales para revisión y correcciones.

## 9. Enlaces del proyecto

- **Herramienta de seguimiento (GitHub Projects):** https://github.com/users/Zanguango/projects/1
- **Repositorio de versiones (GitHub):** https://github.com/Zanguango/SAPO
- **Product Backlog:** https://github.com/Zanguango/SAPO/blob/main/docs/PRODUCT_BACKLOG.md
- **Planificación de Sprint 1:** https://github.com/Zanguango/SAPO/blob/main/docs/SPRINT_1_PLAN.md

---

**Nota de alcance:** S.A.P.O. es un prototipo académico de un escenario simulado con datos exclusivamente ficticios. No se conecta con sistemas policiales, judiciales ni administrativos reales y no contempla el despliegue en producción.
