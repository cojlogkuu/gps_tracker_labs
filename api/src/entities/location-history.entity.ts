import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { Device } from './device.entity';

@Entity('location_history')
export class LocationHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float' })
  latitude: number;

  @Column({ type: 'float' })
  longitude: number;

  @Column()
  deviceId: string;

  @ManyToOne(() => Device, (device) => device.locations, {
    onDelete: 'CASCADE',
  })
  device: Device;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
