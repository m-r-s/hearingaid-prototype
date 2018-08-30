/**
 * Copyright 2018 Marc René Schädler
 *
 * This file is part of the mobile hearing aid prototype project
 * The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.
 */

float feedback1[FEEDBACKLENGTH*TICKSAMPLES] = {0.0};
float feedback2[FEEDBACKLENGTH*TICKSAMPLES] = {0.0};
float playbackbuffer1[FEEDBACKLENGTH*TICKSAMPLES] = {0.0};
float playbackbuffer2[FEEDBACKLENGTH*TICKSAMPLES] = {0.0};
int range1[2] = {0};
int range2[2] = {0};
int tickcount = 0;
