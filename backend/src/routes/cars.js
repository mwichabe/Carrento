const router = require('express').Router();
const { getCars, getCar, createCar, updateCar, deleteCar, checkAvailability } = require('../controllers/carController');
const { protect, adminOnly } = require('../middleware/auth');

router.get('/', getCars);
router.get('/:id', getCar);
router.get('/:id/availability', checkAvailability);
router.post('/', protect, adminOnly, createCar);
router.put('/:id', protect, adminOnly, updateCar);
router.delete('/:id', protect, adminOnly, deleteCar);

module.exports = router;
