import 'package:eduguard/models/academic/academic_class.dart';
import 'package:eduguard/models/academic/student.dart';
import 'package:eduguard/services/classes_repository.dart';
import 'package:eduguard/services/storage/key_value_store.dart';
import 'package:eduguard/services/students_repository.dart';
import 'package:eduguard/viewmodels/academic/classes_view_model.dart';
import 'package:eduguard/viewmodels/academic/students_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClassesViewModel - Edição de Turmas', () {
    test('atualiza os dados de uma turma existente', () async {
      final store = InMemoryKeyValueStore();
      final repository = ClassesRepository(store: store, populateSamples: false);
      final vm = ClassesViewModel(repository: repository);
      await vm.loadClasses();

      const initialClass = AcademicClass(
        id: 'c-1',
        name: 'Turma Original',
        course: 'Computação',
        code: 'CC101',
        studentsCount: 20,
        semester: '2026/1',
        shift: 'Matutino',
        room: 'Sala 1',
        nextClass: 'Segunda 08:00',
      );

      vm.addClass(initialClass);
      expect(vm.filteredClasses.first.name, 'Turma Original');

      final updated = initialClass.copyWith(
        name: 'Turma Atualizada',
        room: 'Sala 102',
      );
      vm.updateClass(updated);

      expect(vm.filteredClasses.first.name, 'Turma Atualizada');
      expect(vm.filteredClasses.first.room, 'Sala 102');

      // Verifica persistência no repositório
      final saved = await repository.getClasses();
      expect(saved.first.name, 'Turma Atualizada');
    });
  });

  group('StudentsViewModel & StudentsRepository - Cadastro e Gestão de Alunos', () {
    test('cadastra, atualiza e remove estudantes com persistência', () async {
      final store = InMemoryKeyValueStore();
      final repository = StudentsRepository(store: store, populateSamples: false);
      const testClass = AcademicClass(
        id: 'turma-teste',
        name: 'Turma Teste',
        course: 'SI',
        code: 'SI-101',
        studentsCount: 0,
        semester: '2026/2',
        shift: 'Noturno',
        room: 'Lab 1',
        nextClass: 'Hoje',
      );

      int countCallback = 0;
      final vm = StudentsViewModel(
        academicClass: testClass,
        repository: repository,
        onStudentsCountChanged: (c) => countCallback = c,
      );

      // Aguarda carga inicial
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(vm.students.isEmpty, isTrue);

      // 1. Cadastrar aluno
      await vm.addStudent(
        name: 'Aluno Teste',
        registration: '2026001',
        email: 'aluno@teste.com',
      );

      expect(vm.students.length, 1);
      expect(vm.students.first.name, 'Aluno Teste');
      expect(vm.students.first.registration, '2026001');
      expect(countCallback, 1);

      // 2. Atualizar aluno
      final student = vm.students.first;
      await vm.updateStudent(student.copyWith(name: 'Aluno Nome Atualizado'));
      expect(vm.students.first.name, 'Aluno Nome Atualizado');

      // 3. Filtrar alunos por busca
      vm.updateSearchQuery('Nome Atualizado');
      expect(vm.students.length, 1);

      vm.updateSearchQuery('NaoExiste');
      expect(vm.students.isEmpty, isTrue);
      vm.clearSearch();

      // 4. Remover aluno
      await vm.removeStudent(student.id);
      expect(vm.students.isEmpty, isTrue);
      expect(countCallback, 0);
    });

    test('serializa e deserializa Student com copyWith, toJson e fromJson', () {
      const student = Student(
        id: 's-1',
        classId: 'c-1',
        name: 'Maria Silva',
        registration: '2026123',
        email: 'maria@faculdade.edu.br',
        attendance: 95,
        averageGrade: 8.5,
      );

      final json = student.toJson();
      final fromJson = Student.fromJson(json);

      expect(fromJson.id, student.id);
      expect(fromJson.name, student.name);
      expect(fromJson.registration, student.registration);
      expect(fromJson.email, student.email);
      expect(fromJson.attendance, student.attendance);
      expect(fromJson.averageGrade, student.averageGrade);
      expect(fromJson.initials, 'MS');

      final copied = student.copyWith(name: 'Maria Souza');
      expect(copied.name, 'Maria Souza');
      expect(copied.registration, '2026123');
    });
  });
}

