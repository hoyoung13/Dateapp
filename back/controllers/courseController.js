// courseController.js
const pool = require('../config/db');
const express = require('express');
const router = express.Router();
// 코스 정보와 각 일정(장소)을 저장하는 함수
const createCourse = async (req, res) => {
  // 요청 본문에서 필요한 정보를 추출합니다.
  const {
    user_id,
    course_name,
    course_description,
    hashtags,      // 예: ['#데이트', '#주말']
    selected_date, // 예: '2025-03-21'
    with_who,      // 예: ['연인과', '친구와']
    purpose,       // 예: ['데이트', '맛집탐방']
    schedules      // 배열: 각 일정 객체 { placeId, placeName, placeAddress, placeImage }
  } = req.body;

  try {
    // 트랜잭션 시작
    await pool.query('BEGIN');

    // courses 테이블에 코스 정보 저장
    const insertCourseQuery = `
      INSERT INTO courses (user_id, course_name, course_description, hashtags, selected_date, with_who, purpose)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id;
    `;
    const courseValues = [
      user_id,
      course_name,
      course_description,
      hashtags,
      selected_date,
      with_who,
      purpose
    ];
    const courseResult = await pool.query(insertCourseQuery, courseValues);
    const courseId = courseResult.rows[0].id;

    // 각 일정(장소)을 course_schedules 테이블에 저장
    const insertScheduleQuery = `
      INSERT INTO course_schedules (course_id, schedule_order, place_id, place_name, place_address, place_image)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id;
    `;

    for (let i = 0; i < schedules.length; i++) {
      const schedule = schedules[i];
      const scheduleValues = [
        courseId,
        i + 1, // 일정 순서 (1부터 시작)
        schedule.placeId,
        schedule.placeName,
        schedule.placeAddress,
        schedule.placeImage
      ];
      await pool.query(insertScheduleQuery, scheduleValues);
    }

    // 모든 쿼리 성공 시 커밋
    await pool.query('COMMIT');
    res.status(201).json({ message: "코스 저장 성공", course_id: courseId });
  } catch (error) {
    // 에러 발생 시 롤백
    await pool.query('ROLLBACK');
    console.error("코스 저장 오류:", error);
    res.status(500).json({ error: "코스 저장에 실패했습니다." });
  }
};
const getCoursesByUser = async (req, res) => {
  try {
    const { user_id } = req.params;

    // 1) courses 테이블에서 해당 user_id의 코스 목록 조회
    const coursesQuery = `
      SELECT *
      FROM courses
      WHERE user_id = $1
      ORDER BY id DESC
    `;
    const coursesResult = await pool.query(coursesQuery, [user_id]);
    const courses = coursesResult.rows;

    // 2) 각 코스마다 schedules 조회하여 합치기
    for (let course of courses) {
      const schedulesQuery = `
        SELECT schedule_order, place_id, place_name, place_address, place_image
        FROM course_schedules
        WHERE course_id = $1
        ORDER BY schedule_order ASC
      `;
      const schedulesResult = await pool.query(schedulesQuery, [course.id]);

      // 코스 객체에 schedules 배열을 추가
      course.schedules = schedulesResult.rows;
    }

    // 응답
    res.status(200).json({ courses });
  } catch (error) {
    console.error("코스 불러오기 오류:", error);
    res.status(500).json({ error: "코스 불러오기 실패" });
  }
};
module.exports = { createCourse,getCoursesByUser };
